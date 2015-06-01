# coding: utf-8
class ReservationsController < ApplicationController
	before_filter :login_required, only: [:index, :rtoaEdit, :atolEdit, :bookReturnEdit, :destroy]
	before_filter :admin_check, except: [:index, :destroy]
	def index
		@tab = flash[:tab]
		if @current_member.name == "admin0" #システム管理者ならば、すべての予約を見れる
			@reservations = Reservation.all
			@reservequeue = ReserveQueue.all
			@availablequeue = AvailableQueue.all
			@lendqueue = LendQueue.all
		elsif @current_member.admin #司書は、属する図書館の予約状況を見れる
			@reservations = Reservation.all
			@reservequeue = ReserveQueue.all
			@availablequeue = AvailableQueue.all
			@lendqueue = LendQueue.all
			logger.debug("貸出キューのチェック#{@lendqueue.inspect}")
		else #一般会員には、自分の予約を見る権限しか与えられていない
			@reservations = Reservation.where("member_id = ?", @current_member.id)
			@reservequeue = ReserveQueue.where("member_id = ?", @current_member.id)
			@availablequeue = AvailableQueue.where("member_id = ?",@current_member.id) 
			@lendqueue = LendQueue.where("member_id = ?", @current_member.id)
		end
	end

	def rtoaEdit #reserve_queue to available_queue Edit
		@libraries = Library.order("id")
	end

	#司書に、本の:isbnと本の所蔵館(:library_id)を入力してもらう
	def rtoaUpdate
		@isbn = params[:isbn]
		@book = Book.where("isbn = ? AND library_id = ?", @isbn, params[:library_id])[0]
		unless @book.present? #本がなかった場合
			redirect_to :rtoaEdit_reservations, notice: "本が見つかりませんでした。"
			return
		else
##########################################システム管理者の場合#################################
			if @current_member.library_id == 0
				@book = Book.where("isbn = ?", @isbn)[0]
				@reserve = ReserveQueue.where("book_id = ?", @book.id)[0]
				unless @reserve.present?
					render "rtoaEdit"
				end
				if @reserve.authority ||  @book.quantity > ((LendQueue.where("book_id = ?", @reserve.book_id).count) + (AvailableQueue.where("book_id = ?", @reserve.book_id).count) + (ReserveQueue.where("book_id = ? AND authority = ?", @reserve.book_id, true).count))
					@available = AvailableQueue.new
					@available.assign_attributes(reservation_id: @reserve.reservation_id, member_id: @reserve.member_id, library_id: @reserve.library_id, book_id: @reserve.book_id)
					if @available.save
						@message = @reserve.member.name
						@reserve.destroy
						flash[:tab] = "tab4"
						redirect_to :reservations, notice: "#{@message}さんの予約を予約状態から貸出可能状態に変更しました"
					end
				else
					logger.debug("前に#{session[:return_to]}にいたでしょ？")
					logger.debug("だめでしたぁ・・・")
					flash[:notice] = "蔵書数が足りません。"
					redirect_to :action => 'rtoaEdit'
				end
				return
			end
##############################################################################################
			#
			if @current_member.library_id > 0 #システム管理者でない場合
				@reserve = ReserveQueue.where("book_id = ? AND library_id = ?", @book.id, @current_member.library_id).order("id")[0]
			else
				@reserve = ReserveQueue.where("book_id = ?", @book.id)
			end
			logger.debug("予約情報のチェック#{@reserve.inspect}")
			unless @reserve.present? #予約情報がなかった場合
				redirect_to :rtoaEdit_reservations, notice: "予約が見つかりませんでした。"
				return
			else
				unless @reserve.present?
					render "rtoaEdit"
					return
				end
				logger.debug("本の冊数#{@book.quantity},予約されている本のID#{@reserve.book_id}")
				if @reserve.authority ||  @book.quantity > ((LendQueue.where("book_id = ?", @reserve.book_id).count) + (AvailableQueue.where("book_id = ?", @reserve.book_id).count) + (ReserveQueue.where("book_id = ? AND authority = ?", @reserve.book_id, true).count))
					@available = AvailableQueue.new
					@available.assign_attributes(reservation_id: @reserve.reservation_id, member_id: @reserve.member_id, library_id: @reserve.library_id, book_id: @reserve.book_id)
					if @available.save!
						@message = @reserve.member.name
						@reserve.destroy
						flash[:tab] = "tab4"
						redirect_to :reservations, notice: "#{@message}さんの予約を予約状態から貸出可能状態に変更しました"
						return
					else
						logger.debug("前に#{session[:return_to]}にいたでしょ？")
						logger.debug("だめでしたぁ・・・")
						redirect_to :action => 'rtoaEdit', notice: "保存処理中にエラーが生じました。"
						return
					end
				else
					logger.debug("前に#{session[:return_to]}にいたでしょ？")
					logger.debug("だめでしたぁ・・・")
					flash[:notice] = "蔵書数が足りません。"
					redirect_to :action => 'rtoaEdit'
					return
				end
			end
		end
	end

	def atolEdit
		@libraries = Library.order("id")
	end

	def atolUpdate
		@isbn = params[:isbn] #本のisbn
		@mail = params[:email]#会員のeメールアドレス
		@member = Member.where("email = ?", @mail)[0]
		@libraries = Library.order("id")
#########################################システム管理者#########################################
		if @current_member.library_id == 0
			unless @member.present?
				redirect_to :atolEdit_reservations, notice: "会員情報が見つかりませんでした。"
				return
			else
				@book = Book.where("isbn = ?", @isbn)[0]
				unless @book.present?
					redirect_to :atolEdit_reservations, notice: "本が見つかりませんでした。"
					return
				else
					@available = AvailableQueue.where("book_id = ? AND member_id = ?", @book.id, @member.id).order("id")[0]
					unless @available.present?
						redirect_to :atolEdit_reservations, notice: "予約情報が見つかりませんでした。"
					else
						@lend = LendQueue.new
						@lend.assign_attributes(reservation_id: @available.reservation_id, member_id: @available.member_id, library_id: @available.library_id, book_id: @available.book_id)
						if @lend.save
							@reserve = Reservation.find_by_id(@available.reservation_id)
							@reserve.assign_attributes(lend_date: Time.now)
							if @reserve.save
								@message = @available.member.name
								@available.destroy
								flash[:tab] = "tab1"
								redirect_to :reservations, notice: "#{@message}さんの予約を貸出可能状態から貸出状態に変更しました(貸出日：#{@reserve.lend_date})"
								return
							else #reservationsに日付登録ができなかった
								logger.debug("だめでしたぁ・・・")
								render "atolEdit"
								return
							end
						end
					end
				end
			end
			return
		end
###############################################################################################
		#
		unless @member.present?
			redirect_to :atolEdit_reservations, notice: "会員情報が見つかりませんでした。"
			return
		else
			@book = Book.where("isbn = ? AND library_id = ?", @isbn, params[:library_id])[0]
			unless @book.present?
				redirect_to :atolEdit_reservations, notice: "本が見つかりませんでした。"
				return
			else
				logger.debug("atolUpdate、会員のデバッグ#{@member.inspect}")
				@available = AvailableQueue.where("book_id = ? AND member_id = ? ", @book.id, @member.id).order("id")[0]
				unless @available.present?
					redirect_to :atolEdit_reservations, notice: "予約情報が見つかりませんでした。"
					return
				else
					@lend = LendQueue.new
					@lend.assign_attributes(reservation_id: @available.reservation_id, member_id: @available.member_id, library_id: @available.library_id, book_id: @available.book_id)
					logger.debug("lendのデバッグ#{@lend.inspect}")
					if @lend.save
						@reserve = Reservation.find_by_id(@available.reservation_id)
						@reserve.assign_attributes(lend_date: Time.now)
						if @reserve.save
							@message = @available.member.name
							@available.destroy
							flash[:tab] = "tab1"
							redirect_to :reservations, notice: "#{@message}さんの予約を貸出可能状態から貸出状態に変更しました(貸出日：#{@reserve.lend_date})"
							return
						else #reservationsに日付登録ができなかった
							logger.debug("だめでしたぁ・・・")
							render "atolEdit"
							return
						end
					else #lend_queueに登録できなかった
						logger.debug("だめでしたぁ・・・")
						render "atolEdit"
						return
					end
				end
			end
		end
	end

	def bookReturnEdit
		@member_id = params[:member_id]	
		if @member_id.present?
			@lend = LendQueue.where("member_id = ?", @member_id)
		end
	end

	def bookReturnUpdate
		@lend = LendQueue.find_by_id(params[:lend_id])
		@reserve = Reservation.find_by_id(@lend.reservation_id)
		@reserve.assign_attributes(return_date: Time.now)
		if @reserve.save
			@book = @lend.book
			@free = @book.quantity - (AvailableQueue.where("book_id = ?", @book.id).count + LendQueue.where("book_id = ?", @book.id).count)
			@next = ReserveQueue.where("book_id = ?", @book.id).order("id").offset(@free)[0]
			@lend.destroy
			@message = "#{@lend.member.name}さんの予約を貸出状態から返却状態にしました(返却日：#{@reserve.return_date})。"
			if @next.present? #もし、貸出可能状態に移行出来る予約が見つかれば
				if @book.library_id == @next.library_id
					@toAvail = AvailableQueue.new
					@toAvail.assign_attributes(reservation_id: @next.reservation_id, member_id: @next.member_id, library_id: @next.library_id, book_id: @next.book_id)
					@next.destroy
					if @toAvail.save
						@message = @message + "また、貸出可能状態に遷移出来る予約が生じたので、受け取り可通知を行いました。"
					end
				else
					@next.authority = true
					@next.save!
					@message = @message + "また、貸出可能状態に遷移出来る予約が生じたので、本を割り当てました。"
				end
			end
			flash[:tab] = "tab3"
			redirect_to :reservations, notice: @message
			return
		else
			redirect_to action: 'bookReturnEdit', notice: (@message.present?) ? @message : "セーブ出来ませんでした。"
			logger.debug("だめでしたぁ・・・")
			return
		end
	end

	def destroy
		@reserve = ReserveQueue.where("id = ?", params[:reserve_id])[0]
		logger.debug("フォームから来た:#{params[:reserve_id]}")
		logger.debug("そして、こいつを使って#{@reserve.inspect}を検索した。")
		cnt = 0
		if @reserve.present? || (@reserve.present? && @current_member.admin)
			@reserve.destroy
			@message = "予約の削除が完了しました。"
		else
			@message = "削除出来る予約がありません。"
		end
		flash[:notice] = @message
		flash[:tab] = 'tab2'
		redirect_to action: 'index'
		return
	end
end
