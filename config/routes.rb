LibraryManager::Application.routes.draw do
	root to: "top#index"

	resources :books, except: [:edit, :update, :destroy]  do
		get "search", on: :collection #本の検索
		put "reserve", on: :member    #本の予約
	end

	resources :notices
	resources :reservations, except: :show do
		get "rtoaEdit", on: :collection
		put "rtoaUpdate", on: :collection
		get "atolEdit", on: :collection
		put "atolUpdate", on: :collection
		get "bookReturnEdit", on: :collection
		put "bookReturnUpdate", on: :collection
	end
	resource :session, only: [:new, :create, :destroy]
	resources :members
	resources :libraries, only: [:index]
	
	match "*anything" => "top#not_found"
end
