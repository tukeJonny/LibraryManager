# coding: utf-8
class NoticesController < ApplicationController
	before_filter :login_required, only: [:new, :create, :edit, :update, :destroy]
	before_filter :admin_check, only: [:new, :create, :edit, :update, :destroy]
	before_filter :notice_updatable, only: [:edit, :update, :destroy]

	def index
		@notices = Notice.order("released_at DESC").paginate(page: params[:page], per_page: 15)
	end

	def show
		@notice = Notice.find(params[:id])
	end

	def new
		@libraries = Library.order("id")
		@notice = Notice.new 
	end

	def create
		@libraries = Library.order("id")
		@notice = Notice.new(params[:notice])
		if @notice.save
			flash[:notice] = "ニュース記事を登録しました。"
			redirect_to @notice
			return
		else
			render "new"
			return
		end
	end

	def edit
		@libraries = Library.order("id")
		@notice = Notice.find(params[:id])
	end

	def update
		@libraries = Library.order("id")
		@notice = Notice.find(params[:id])
		@notice.assign_attributes(params[:notice])
		if @notice.save
			flash[:notice] = "ニュース記事を更新しました。"
			redirect_to @notice
			return
		else
			render "edit"
			return
		end
	end

	def destroy
		@notice = Notice.find(params[:id])
		@notice.destroy
		redirect_to :notices, notice: "ニュース記事を削除しました。"
		return
	end
end
