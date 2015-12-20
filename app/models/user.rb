class User < ActiveRecord::Base
  devise :cas_authenticatable

  def cas_extra_attributes=(extra_attributes)
    self.nickname = (extra_attributes.try(:[], "nickname") || self.nickname)
  end
end
