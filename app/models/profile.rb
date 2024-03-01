class Profile < ApplicationRecord
  belongs_to :user

  # validates :user_id, presence: true
  # validates :img_url, presence:true

  def self.profile_img(user_id)
    profile = Profile.where(user_id:)
    profile[0]['img_url']
  end

  def new_attributes
    { id:, img_url: '', name:, email: }
  end
end
