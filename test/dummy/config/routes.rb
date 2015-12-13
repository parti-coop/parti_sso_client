Rails.application.routes.draw do
  sso_devise

  root 'pages#index'
  resources :pages
  get :sso, to: 'pages#sso'
end
