require 'open-uri'
require 'json'

class User < ActiveRecord::Base
  devise :cas_authenticatable

  def cas_extra_attributes=(extra_attributes)
    self.nickname = (extra_attributes.try(:[], "nickname") || self.nickname)
  end

  def self.sync(key)
    url = "#{URI.join(Devise.cas_base_url, 'users/fetch.json')}?#{{key: key}.to_query}"
    result = JSON.parse(open(url).read)
    user = User.find_or_initialize_by email: result["user"]["email"]
    user.assign_attributes result["user"]
    user if user.save!
  rescue => e
    logger.error e
    nil
  end
end
