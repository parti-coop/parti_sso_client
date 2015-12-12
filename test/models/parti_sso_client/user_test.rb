require 'test_helper'

module PartiSsoClient
  class UserTest < ActiveSupport::TestCase
    def setup
    end

    test 'can save a user' do
      email = 'foo@bar.com'
      user = new_user(email: email)

      assert_equal email, user.email
      user.save!
      assert_equal email.downcase, user.email
    end

    test 'should have "cas_authenticatable" devise strategy' do
      assert Devise.mappings[:user].strategies.include?(:cas_authenticatable)
    end
  end
end
