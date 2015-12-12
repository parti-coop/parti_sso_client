Rails.application.routes.draw do
  sso_devise

  resources :pages
  get :sso_path, to: 'pages#sso'
end
