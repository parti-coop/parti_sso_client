require 'active_support/test_case'

class ActiveSupport::TestCase
  VALID_AUTHENTICATION_TOKEN = 'AbCdEfGhIjKlMnOpQrSt'.freeze

  def valid_attributes(attributes={})
    { email: generate_unique_email }.update(attributes)
  end

  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@example.com"
  end

  def new_user(attributes={})
    PartiSsoClient::User.new(valid_attributes(attributes))
  end
end
