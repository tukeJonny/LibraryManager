# coding: utf-8
class BooksController < ApplicationController
	before_filter :login_required, only: [:new, :create, :index, :reserve]
	before_filter :not_system_manager_check, only: [:new, :create]
	before_filter :admin_check, only: [:index, :new, :create]

	def index
		@books = Book.order("id").paginate(page: params[:page], per_page: 15)
	end

	def show
		Amazon::Ecs.debug = true
		@book = Amazon::Ecs.item_search(params[:id], {:search_index => 'Books',:response_group => 'Medium'})
		logger.debug("検索した結果:#{@book.inspect}")
		if (@book.present? && @book.items[0].present?) &&  Book.where("isbn = ?", isbn10_to_13(@book.items[0].get('ItemAttributes/ISBN')))[0].present?
			@libraries = Library.order("id")	 
		else 
			redirect_to search_books_path, notice: "指定された本は蔵書されておりません。"
			return
		end
	end

	def new
	end

	def create
		@isbn = params[:isbn].to_i
		if @isbn < 1000000000 || !params[:quantity].present?
			redirect_to :books, notice: "項目を正しく入力してください"
			return
		end
		Amazon::Ecs.debug = true
		@res = Amazon::Ecs.item_search(@isbn,:search_index => 'Books',:response_group => 'Medium').items[0]
		if @res == nil
			redirect_to :books, notice: "指定したisbnの本は存在しません。"
			return
		else
			@book = Book.find_by_isbn_and_library_id(@isbn, params[:library_id])
			if !@book.present?			#図書DBにない場合
				@book = Book.new
				@book.isbn = @isbn
				@book.library_id = params[:library_id].to_i
				@book.quantity = params[:quantity].to_i
				if @book.save!
					redirect_to :books, notice: "#{@res.get('ItemAttributes/Title')}を#{params[:quantity]}冊追加しました。"
					return
				else
					redirect_to :books, notice: "保存出来ませんでした。"
					return
				end
			else				#図書DBにすでにある場合
				@add = params[:quantity].to_i
				@book.quantity = @book.quantity + @add
				if @book.save!
					############受け取り可に遷移する予約があるかチェック####################
					@reserve = ReserveQueue.where("book_id = ?", @book.id).count
					@limit = (@add > @reserve) ? @reserve : @add
					cnt = 0
					for r in 0...@limit do
						#1冊1冊づつ蔵書が追加されるものと考え、処理毎に蔵書が追加される前の蔵書数を考える
						#rは、現時点での蔵書追加冊数を表している
						@free = (@book.quantity - @add + r) - (AvailableQueue.where("book_id = ?", @book.id).count + LendQueue.where("book_id = ?", @book_id).count)
						@next = ReserveQueue.where("book_id = ?", @book.id).order("id").offset(@free)[0]
						if @next.present?
							logger.debug("@next = #{@next.inspect}が成功しました。")
							if @book.library_id == @next.library_id
								@toAvail = AvailableQueue.new
								@toAvail.assign_attributes(reservation_id: @next.reservation_id, member_id: @next.member_id, library_id: @next.library_id, book_id: @next.book_id)
								@next.destroy
								if @toAvail.save!
									cnt = cnt + 1
								end
								logger.debug("追加")
							else
								logger.debug("A Bの組み合わせなので、割り当てるだけで、AvailableQueueには移さない")
								@next.authority = true #割り当てる
								@next.save!
								cnt = cnt + 1
							end
						end
					end
					@message = "#{@res.get('ItemAttributes/Title')}を#{@add}冊だけ追加し" + ((cnt > 0) ? "、#{cnt}人分の予約に対して、受け取り可通知や割り当てを行いました。" : "ました。")
					redirect_to :books, notice: @message
					return
				end
			end
		end
	end

	def search
		@libraries = Library.order("id") #図書館情報 
		@keyword = params[:keyword] #キーワード
		@genre_code = params[:genre_code] #ジャンル
		@lib_id = params[:lib_id]
		@result = [] #検索結果の配列
		if @keyword.present? || @genre_code.present?
			Amazon::Ecs.debug = true
			@res = Amazon::Ecs.item_search(@keyword, {:search_index => 'Books', :response_group => 'Medium', :BroseNode => @genre_code })
			@res.items.each do |book|
				data = isbn10_to_13(book.get('ItemAttributes/ISBN')).to_i
				if data > 1000000000000
					if @lib_id == ""
						@book = Book.find_by_isbn(data)
					else
						@book = Book.find_by_isbn_and_library_id(data, @lib_id)
					end
					if @book != nil
						@result << [book.get('SmallImage/URL'), book.get('ItemAttributes/Title'), book.get('ItemAttributes/Author'), @book] #検索結果に追加
					end
				end
			end
		end
	end

	def reserve
		logger.debug("リクエストデバッグ#{request.body.read}")
		@passLib_id = params[:uketori_lib_id]
		@haveLib_id = params[:syozou_lib_id]
		@book_id = params[:book_id]
		@quantity =  params[:q].to_i
		logger.debug("パラメータデバッグ#{params}")

		@reservation = Reservation.new
		@reservation.assign_attributes(book_id: @book_id, member_id: @current_member.id, library_id: @passLib_id)
		@reservation.save!
		logger.debug("かけていないかチェックします：1.#{@reservation.inspect}, 2.#{@current_member.inspect}, 3.#{@passLib_id.inspect}, 4.#{@book_id.inspect}")
		#所蔵館と受取館が一致 && 予約する本について、貸出可能もしくは貸出中の冊数合計が所蔵数より小さい && 先に予約している人がいない ならばAvailableQueueに追加する。
		if  @passLib_id == @haveLib_id && @quantity > AvailableQueue.where("book_id = ?", @book_id).count + LendQueue.where("book_id = ?", @book_id).count + ReserveQueue.where("book_id = ?", @book_id).count 
			@availablequeue = AvailableQueue.new
			@availablequeue.assign_attributes(reservation_id: @reservation.id, member_id: @current_member.id, library_id: @passLib_id, book_id: @book_id)
			@availablequeue.save!
			flash[:tab] = 'tab4'
			logger.debug("Availableに無事入れたようだね！ここでちぇーっく#{@availablequeue.inspect}")
		else
			@auth = false
			if @quantity > AvailableQueue.where("book_id = ?", @book_id).count + LendQueue.where("book_id = ?", @book_id).count + ReserveQueue.where("book_id = ? AND authority = ?", @book_id, true).count
				@auth = true
			end
			@reservequeue = ReserveQueue.new
			@reservequeue.assign_attributes(reservation_id: @reservation.id, member_id: @current_member.id, library_id: @passLib_id, book_id: @book_id, authority: @auth)
			@reservequeue.save!
			flash[:tab] = 'tab2'
			logger.debug("Reserveに無事入れたようだね！ここでちぇーっく#{@reservequeue.inspect}")
		end
		flash[:notice] = "予約が完了しました。"
		redirect_to controller: 'reservations' ,action: 'index'
		return
	end


	private
	def isbn10_to_13(isbn10)
		isbn13 = "978#{isbn10.to_s[0..8]}"
		#チェックディジット計算用
		check_digit = 0
		arr = isbn13.split(//)
		arr.each_with_index do |chr, idx|
			#Integer.even?はActiceSupportによる拡張
			check_digit += chr.to_i * (idx % 2 == 0 ? 1 : 3)
		end
		#総和を10で割ったものを10から引き、10の場合には0にする
		check_digit = (10 - (check_digit % 10)) % 10
		return "#{isbn13}#{check_digit}".to_i
	end

	def isbn13_to_10(isbn13)
		isbn10 = isbn13.to_s[3..11]
		check_digit = 0
		arr = isbn10.split(//)
		arr.each_with_index do |chr, idx|
			check_digit += chr.to_i * (10 - idx)
		end
		check_digit = 11 - (check_digit % 11)
		#計算結果が10になった場合、10の代わりにX(アルファベット大文字)
		#また、11になった場合は0となる。
		case check_digit
		when 10
			check_digit = "X"
		when 11
			check_digit = 0
		end
		return "#{isbn10}#{check_digit}".to_i
	end

	def toAvailable #available_queueに入るか否か
		@isbn = params[:isbn]
		@book = Book.where("isbn = ? AND library_id = ?", @isbn, params[:library_id])[0]
		@reserve = ReserveQueue.where("book_id = ?", @book.id).order("id")[0]
		return(false) unless @reserve.present?
		logger.debug("本の冊数#{@book.quantity},予約されている本のID#{@reserve.book_id}")
		if @book.quantity > ((LendQueue.where("book_id = ?", @reserve.book_id).count) + (AvailableQueue.where("book_id = ?", @reserve.book_id).count))
			@available = AvailableQueue.new
			@available.assign_attributes(reservation_id: @reserve.reservation_id, member_id: @reserve.member_id, library_id: @reserve.library_id, book_id: @reserve.book_id)
			if @available.save
				@reserve.destroy
				return true
			else
				return false
			end
		else 
			logger.debug("前に#{session[:return_to]}にいたでしょ？")
			logger.debug("だめでしたぁ・・・")
			return false
		end 
	end
end

