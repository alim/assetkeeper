AssetKeeper::Application.routes.draw do
  resources :asset_items

  resources :manufacturers do
    resources :contacts
  end

  resources :projects

  resources :subscriptions

  resources :organizations do
  	# Route for notifying and re-invite
		member do
			put 'notify'
		end
	end

  # The path_prefix sets up path helpers to prepend /auth to them
  # devise_for :users, path_prefix: 'auth'
  devise_for :users, path_prefix: 'auth', controllers: { registrations: :registrations }

	resources :users do
	  # Account is an embedded document for a user with limited actions
	  resources :accounts, only: [:new, :create, :edit, :update, :destroy]
	end

  get   "home/index"
  get   "home/pricing"
  get   "home/demo"
  get   "home/support"
  get   "home/contact"
  post  "home/create_contact"
  get   "home/about"
  get   "admin/help"
  get   "admin/index"
  get   "admin/oops"
  get   "admin/calendar"

  get "admin" => 'admin#index'

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'home#index'
end
