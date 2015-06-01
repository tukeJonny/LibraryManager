class LibrariesController < ApplicationController
	def index
		@libraries = Library.order("id")
	end
end
