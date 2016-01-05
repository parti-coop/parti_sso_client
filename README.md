# Parti SSO Client

This project rocks and uses MIT-LICENSE.

## Install

Gemfile

```
gem 'parti_sso_client', github: 'parti-xyz/parti_sso_client'
```

config/routes.rb

```
Rails.application.routes.draw do
  ...
  sso_devise
  ...
end
```

config/secrets.yml
```
development:
  ...
  sso_secret_key_base: 11f47da88f28f287add2221f081f3972af887cec7649650e1eb4728a6b4e9f3814cdd6632e7b550704cb90ffd15183cc53d6beb31e7d5a2112b891dc807be21c
  sso_encrypted_cookie_salt: 'Zx4?=P:soCe|l-Ib={iPikI5lty,-Cd<LC7gPxoOY4/g5HxG,4nGDj)wsfl|:65;'
  sso_encrypted_signed_cookie_salt: '$Y8WOE[kfE(|::q|P#LgINM4]^&>!&5O*xCOcO~ka74d$-*xxZI+NKsNgTrtB$9#'

...

production:
  ...
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  sso_secret_key_base: <%= ENV["SSO_SECRET_KEY_BASE"] %>
  sso_encrypted_cookie_salt: <%= ENV["SSO_ENCRYPTED_COOKIE_SALT"] %>
  sso_encrypted_signed_cookie_salt: <%= ENV["SSO_ENCRYPTED_SIGNED_COOKIE_SALT"] %>
  sso_session_key: <%= ENV["SSO_SESSION_KEY"] %>
```

config/initializers/session_store.rb
```
Rails.application.config.session_store :cookie_store, key: NEED_TO_CHANGE, domain: :all
```

app/controllers/application_controller.rb
```
  include PartiSsoClient::Authentication
  before_action :verify_authentication
```

for mobile application
```
  include PartiSsoClient::TokenAuthentication

  token_user
  token_authenticated?
```

## Test

test/test_helper.rb

```
require 'parti_sso_client/test_helpers'

class ActionDispatch::IntegrationTest
  include PartiSsoClient::TestHelpers
end
```

sample

```
sign_in(user)
```
