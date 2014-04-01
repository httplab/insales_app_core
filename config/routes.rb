Rails.application.routes.draw do
  get '/accounts/install' => 'accounts#install'
  get '/accounts/uninstall' => 'accounts#uninstall'

  resource :session, only: [:new, :create, :destroy] do
    get :autologin
  end

  resource :account_settings, only: [:edit, :update]

  resources :categories, only: [:index] do
    get :tree, on: :collection
  end
end
