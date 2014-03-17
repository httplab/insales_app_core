Rails.application.routes.draw do
  get '/accounts/install' => 'accounts#install'
  get '/accounts/uninstall' => 'accounts#uninstall'
end
