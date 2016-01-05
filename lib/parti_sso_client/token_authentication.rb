module PartiSsoClient
  module TokenAuthentication
    extend ActiveSupport::Concern

    def token_user
      @token_user ||= fetch_from_token
    end

    def token_authenticated?
      token_user.present?
    end

    private

    TOKEN_KEY = 'token='
    TOKEN_REGEX = /^Token /
    AUTHN_PAIR_DELIMITERS = /(?:,|;|\t+)/

    def fetch_from_token
      token, options = token_and_options headers["Authorization"]
      unless token.blank?
        user = User.find_by(email: options[:email])
        return nil if user.nil?

        current_api_key = ApiKey.find_by({
          client: options[:client],
          user: user
        })
        return nil unless current_api_key.try(:authenticated?, token)

        return user
      end
    end

    def token_and_options(request)
      authorization_request = headers["Authorization"].to_s

      if authorization_request[TOKEN_REGEX]
        params = token_params_from authorization_request
        [params.shift[1], Hash[params].with_indifferent_access]
      end
    end

    def token_params_from(auth)
      rewrite_param_values params_array_from raw_params auth
    end

    def raw_params(auth)
      _raw_params = auth.sub(TOKEN_REGEX, '').split(/\s*#{AUTHN_PAIR_DELIMITERS}\s*/)

      if !(_raw_params.first =~ %r{\A#{TOKEN_KEY}})
        _raw_params[0] = "#{TOKEN_KEY}#{_raw_params.first}"
      end

      _raw_params
    end

    def params_array_from(raw_params)
      raw_params.map { |param| param.split %r/=(.+)?/ }
    end

    def rewrite_param_values(array_params)
      array_params.each { |param| (param[1] || "").gsub! %r/^"|"$/, '' }
    end
  end
end
