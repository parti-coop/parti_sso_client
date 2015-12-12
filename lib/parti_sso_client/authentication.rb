module PartiSsoClient
  module Authentication
    extend ActiveSupport::Concern

    SSO_SESSION_COOKIE_NAME = '_parti-sso_session'

    included do
      hide_action :verify_authentication
    end

    def verify_authentication(signin_path)
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

          redirect_to signin_path and return
        end
      end

      session.delete :sso_filtering
    end

    def diff_auth?
      (user_signed_in? != sso_signed_in?) or
      (current_user.try(:email) != sso_current_username)
    end

    def sso_signed_in?
      sso_session.has_key? "cas_username"
    end

    def sso_current_username
      return nil unless sso_signed_in?

      sso_session["cas_username"]
    end

    def sso_session
      @cookie ||= cookies.fetch(PartiSsoClient::Authentication::SSO_SESSION_COOKIE_NAME, nil)
      @sso_session ||= decrypt_session_cookie(@cookie)
    end

    private

    def decrypt_session_cookie(cookie)
      return {} if cookie.nil?
      cookie = CGI.unescape(cookie)
      config = Rails.application.config

      encrypted_cookie_salt = config.action_dispatch.encrypted_cookie_salt               # "encrypted cookie" by default
      encrypted_signed_cookie_salt = config.action_dispatch.encrypted_signed_cookie_salt # "signed encrypted cookie" by default

      key_generator = ActiveSupport::KeyGenerator.new(secrets.secret_key_base, iterations: 1000)
      secret = key_generator.generate_key(encrypted_cookie_salt)
      sign_secret = key_generator.generate_key(encrypted_signed_cookie_salt)

      encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret, serializer: ActiveSupport::MessageEncryptor::NullSerializer)
      JSON.parse encryptor.decrypt_and_verify(cookie)
    end

    def secrets
      @secrets ||= begin
        config = Rails.application.config
        secrets = ActiveSupport::OrderedOptions.new
        yaml = config.paths["config/secrets"].first

        if File.exist?(yaml)
          require "erb"
          all_secrets = YAML.load(ERB.new(IO.read(yaml)).result) || {}
          env_secrets = all_secrets[Rails.env]
          secrets.merge!(env_secrets.symbolize_keys) if env_secrets
        end

        # Fallback to config.secret_key_base if secrets.secret_key_base isn't set
        secrets.secret_key_base ||= config.secret_key_base

        secrets
      end
    end
  end
end
