Rails.application.routes.draw do
  sso_devise

  root 'pages#index'
  resources :pages
  get :sso, to: 'pages#sso'

  mount API::V1::Base, at: "/"
end
