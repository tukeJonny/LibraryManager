#coding: utf-8
class SessionsController < ApplicationController
	def new
	end

	def create
		member = Member.authenticate(params[:name], params[:password])
		if member
			session[:member_id] = member.id
			logger.debug("ログイン完了")
		else
			logger.debug("ログイン失敗")
			flash.alert = "名前とパスワードが一致しません"
			redirect_to :root, notice: "ユーザIDが間違っている、もしくはパスワードが間違っています。"
			return
		end
		redirect_back_or_default(:root)
		return
	end

	def destroy
		session.delete(:member_id)
		logger.debug("ログアウト完了。さようなら")
		redirect_to :root
		return
	end

	private
	def redirect_back_or_default(default)
		redirect_to(session[:return_to] || :root)
		session[:return_to] = nil
		return
	end
end
