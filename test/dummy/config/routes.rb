Rails.application.routes.draw do

  mount PartiSsoClient::Engine => "/parti_sso_client"
end
