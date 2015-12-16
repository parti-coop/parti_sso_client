require 'active_support/test_case'

class ActiveSupport::TestCase
  def valid_attributes(attributes={})
    { email: generate_unique_email, nickname: generate_unique_nickname }.update(attributes)
  end

  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "test#{@@email_count}@example.com"
  end

  def generate_unique_nickname
    @@nickname_count ||= 0
    @@nickname_count += 1
    "nick#{@@nickname_count}"
  end

  def new_user(attributes={})
    User.new(valid_attributes(attributes))
  end
end
