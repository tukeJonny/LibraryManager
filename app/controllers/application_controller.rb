# coding: utf-8
class ApplicationController < ActionController::Base
	protect_from_forgery

	before_filter :authorize

	class Forbidden < StandardError; end
	class NotFound < StandardError; end


	private
	#ログイン用アクション
	def authorize
		@current_member = Member.find_by_id(session[:member_id])
		session.delete(:member_id) unless @current_member
	end
	#フィルター：ログイン要求
	def login_required
		raise Forbidden unless @current_member
	end
	#フィルター：権限持ちであるかチェック
	def admin_check
		raise Forbidden unless @current_member.admin
	end
	#フィルター：システム管理者でないかチェック
	def not_system_manager_check
		logger.debug("システム管理者？")
		raise Forbidden if @current_member.library_id == 0
	end
	#フィルター：管理者であるか、もしくは自分の詳細を見ようとしているかチェック
	def member_check
		logger.debug("他の人の会員情報を見ようとしていない？")
		@member = Member.find(params[:id])
		raise Forbidden unless @current_member.admin || @member.id == @current_member.id
	end
	#フィルター：未ログイン状態であるかチェック
	def before_login
		logger.debug("まだログインしていない？")
		raise Forbidden unless !@current_member
	end
	#会員情報を編集及び削除できるかチェック
	def member_updatable
		logger.debug("会員情報を変更できる？")
		@member = Member.find(params[:id])
		raise Forbidden if @current_member.library_id != 0 && @current_member.id != @member.id && @member.admin
	end
	#お知らせを編集及び削除できるかチェック
	def notice_updatable
		@notice = Notice.find(params[:id])
		raise Forbidden unless @current_member.library_id == 0 || @current_member.library_id == @notice.library_id
	end

	if Rails.env.production?
		rescue_from Exception, with: :rescue_500
		rescue_from ActionController::RoutingError, with: :rescue_404
		rescue_from ActiveRecord::RecordNotFound, with: :rescue_404
	end

	rescue_from Forbidden, with: :rescue_403
	rescue_from NotFound, with: :rescue_404

	def rescue_403(exception)
		render "errors/forbidden", status: 403, layout: "error"
		return
	end

	def rescue_404(exception)
		render "errors/not_found", status: 404, layout: "error"
		return
	end

	def rescue_500(exception)
		render "errors/internal_server_error", status: 500, layout: "error"
		return
	end
end
