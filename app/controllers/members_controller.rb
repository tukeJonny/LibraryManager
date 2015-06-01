# coding: utf-8
class MembersController < ApplicationController
	before_filter :login_required, except: [:new, :create]
	before_filter :admin_check, only: :index
	before_filter :member_check, only: [:show, :edit]
	before_filter :before_login, only: :new
	before_filter :member_updatable, only: [:edit, :destroy]

	def index
		@members = Member.order("id").paginate(page: params[:page], per_page: 15)
		logger.debug("念の為、会員デバッグ#{@members.inspect}")
	end

	def show
		logger.debug("これはあなたです")
		logger.debug(@current_member.inspect) 
		@member = Member.find(params[:id])
		logger.debug("これは詳細の人")
		logger.debug(@member.inspect)
		return
	end

	def new
		@member = Member.new
		@libraries = Library.order("id")
	end

	def create
		@libraries = Library.order("id")
		@member = Member.new(params[:member])
		if @member.save
			session[:member_id] = @member.id
			redirect_to member_path(@member), notice: "会員情報を登録しました。"
			#@mail = NoticeMailer.complete_registration(@member9).deliver
			return
		else
			flash[:notice] = "記入項目を確認してください"
			redirect_to action: 'new', notice: "記入項目を確認してください"
			return
		end
	end

	def edit
		@member = Member.find(params[:id])
		@libraries = Library.order("id")
	end

	def update
		@member = Member.find(params[:id])
		@member.assign_attributes(params[:member])
		if @member.save && @member.name.present? && @member.user_id.present?
			redirect_to @member, notice: "会員情報を更新しました。"
			return
		else
			flash[:notice] = "更新に失敗しました。"
			redirect_to action: "edit"
			return
		end
	end

	def destroy
		logger.debug("どうも、destroyアクションです。")
		@member = Member.find(params[:id])
		@reserve = ReserveQueue.where("member_id = ?", @member.id)
		@auth = ReserveQueue.where("member_id = ? AND authority = ?", @member.id, true).count
		logger.debug("割り当ては#{@auth}つ")
		logger.debug("予約をチェックしま〜す")
		if  !AvailableQueue.where("member_id = ?", @member.id).exists? && !LendQueue.where("member_id = ?", @member.id).exists? && (@current_member.library_id == @member.library_id || @current_member.library_id == 0) && @auth == 0
			logger.debug("うん、これは削除していいね")
			@reserve.each do |reserve|
				reserve.destroy
			end
			logger.debug("予約の削除完了〜")
			id = @member.id
			@member.destroy
			logger.debug("会員の削除完了〜")
			redirect_to (@current_member.admin && @current_member.id != id) ? :members : :root, notice: "会員情報を削除しました。"
			return
		else
			logger.debug("この会員は削除しちゃだめだなぁ・・・")
			redirect_to member_path(@member.id), notice: "削除しようとした会員の予約が貸出可能状態もしくは貸出状態にある、あるいは権限が認められないため、削除を実行できません。"
			return
		end
	end
end
