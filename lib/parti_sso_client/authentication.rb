module PartiSsoClient
  module Authentication
    extend ActiveSupport::Concern

    included do
      hide_action :verify_authentication
    end

    def verify_authentication(sign_in_path)
      return if devise_controller?

      session[:user_return_to] = request.original_url if request.get?

      if diff_auth?
        if user_signed_in?
          sign_out current_user
        end
        if sso_signed_in?
          # block to too many redirectoin
          if session.has_key? :sso_filtering
            return
          else
            session[:sso_filtering] = true
          end

          redirect_to sign_in_path and return
        end
      end

      session.delete :sso_filtering

    end

    def diff_auth?
      (user_signed_in? != sso_signed_in?) or
      (current_user.try(:email) != sso_current_username)
    end

    def sso_signed_in?
      sso_session.has_key? sso_session_username_key
    end

    def sso_current_username
      return nil unless sso_signed_in?

      sso_session[sso_session_username_key]
    end

    def sso_session
      @cookie ||= cookies.fetch(sso_session_key, nil)
      @sso_session ||= decrypt_session_cookie(@cookie)
    end

    private

    def decrypt_session_cookie(cookie)
      return {} if cookie.nil?
      cookie = CGI.unescape(cookie)
      key_generator = ActiveSupport::KeyGenerator.new(sso_secret_key_base, iterations: 1000)
      secret = key_generator.generate_key(sso_encrypted_cookie_salt)
      sign_secret = key_generator.generate_key(sso_encrypted_signed_cookie_salt)

      encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret, serializer: ActiveSupport::MessageEncryptor::NullSerializer)
      JSON.parse encryptor.decrypt_and_verify(cookie)
    end

    def sso_secret_key_base
      @sso_secret_key_base ||= (rails_secrets.sso_secret_key_base || rails_secrets.secret_key_base)
    end

    def sso_encrypted_cookie_salt
      @sso_encrypted_cookie_salt ||= (rails_secrets.sso_encrypted_cookie_salt || rails_config_action_dispatch.encrypted_cookie_salt)
    end

    def sso_encrypted_signed_cookie_salt
      @sso_encrypted_signed_cookie_salt ||= (rails_secrets.sso_encrypted_signed_cookie_salt || rails_config_action_dispatch.encrypted_signed_cookie_salt)
    end

    def sso_session_key
      @sso_session_key ||= (rails_secrets.sso_session_key || '_parti-sso_session')
    end

    def sso_session_username_key
      @sso_session_username_key ||= (rails_secrets.sso_session_username_key || 'cas_username')
    end

    def rails_config_action_dispatch
      Rails.application.config.action_dispatch
    end

    def rails_secrets
      Rails.application.secrets
    end
  end
end
