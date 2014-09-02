Rails.application.routes.draw do
  get '/accounts/install' => 'accounts#install'
  get '/accounts/uninstall' => 'accounts#uninstall'

  resource :session, only: [:new, :create, :destroy] do
    get :autologin
  end

  scope '/settings' do
    resource :account_settings, path: '/account', only: [:edit, :update]
  end

  resources :categories, only: [:index] do
    get :tree, on: :collection
  end

  get "/pages/*id" => 'pages#show', format: false
end
