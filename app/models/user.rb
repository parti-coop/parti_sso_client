require 'open-uri'
require 'json'

class User < ActiveRecord::Base
  devise :cas_authenticatable
  has_many :api_keys, class_name: PartiSsoClient::ApiKey

  def cas_extra_attributes=(extra_attributes)
    self.nickname = (extra_attributes.try(:[], "nickname") || self.nickname)
  end

  def self.sync(key)
    url = "#{URI.join(Devise.cas_base_url, 'users/fetch.json')}?#{{key: key}.to_query}"
    result = JSON.parse(open(url).read)
    user = User.find_or_initialize_by email: result["username"]
    user.cas_extra_attributes = result["extra_attributes"]
    user if user.save!
  rescue => e
    logger.error e
    nil
  end

  def image_url
    "#{Devise.cas_base_url}users/images/#{nickname}"
  end
end
