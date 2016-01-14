require 'parti_sso_client/authentication'

module PartiSsoClient
  module TestHelpers
    def self.included(base)
      base.class_eval do
        setup :_make_casino_to_yesman, :_ignore_verifying_authentication if respond_to?(:setup)
      end
    end

    def sign_in(user)
      scope = Devise::Mapping.find_scope!(user)
      devise_mapping = Devise.mappings[scope]
      path = Devise.cas_service_url('', devise_mapping)
      get path, ticket: user.email
    end

    def sign_out(user)
      scope = Devise::Mapping.find_scope!(user)
      delete send(:"destroy_#{scope}_session_path")
    end

    protected

    def _make_casino_to_yesman
      class <<Devise.cas_client
        def validate_service_ticket(st)
          st.user = st.ticket
          st.success = true
          return st
        end
      end
    end

    def _ignore_verifying_authentication
      PartiSsoClient::Authentication.ignored_verifying_authentication = true
    end

  end
end
