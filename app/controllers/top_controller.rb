class TopController < ApplicationController
	def index
		@notices = Notice.where("updated_at >= ?", Time.now.advance(:days => -3)).order("id")
	end

	def not_found
		raise ActionController::RoutingError, "No route matches #{request.path.inspect}"
	end
end
