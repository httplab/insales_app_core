require 'sidekiq/web'

Rails.application.routes.draw do
  sidekiq_app = Rack::Auth::Basic.new(Sidekiq::Web) do |username, password|
    username == ENV['SIDEKIQ_AREA_USER'] && password == ENV['SIDEKIQ_AREA_PASS']
  end

  mount sidekiq_app, at: '/sidekiq'

  mount sidekiq_app, at: '/sidekiq'

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

  namespace :admin do
    resources :accounts, only: :index
    root to: redirect('/admin/accounts')
  end

  get "/pages/*id" => 'pages#show', format: false
end
