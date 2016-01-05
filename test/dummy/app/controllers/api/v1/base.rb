module API
  module V1
    class Base < Grape::API
      version 'v1', using: :path
      format :json
      prefix "api"

      helpers PartiSsoClient::TokenAuthentication

      get "do_something" do
        if token_authenticated?
          { user: { email: token_user.email } }
        else
          { error: 'unauthenticated' }
        end
      end
    end
  end
end
