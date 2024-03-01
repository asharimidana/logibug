class User < ApplicationRecord
  has_many :members, dependent: :destroy
  has_many :projects, through: :members, dependent: :destroy

  has_one :profile, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  has_secure_password

  # before_destroy :delete_projects_as_po

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: true
  validates :password, length: { minimum: 8 }, presence: true
  # validates :password_confirmation, length: { minimum: 8 }, presence: true

  # ===== user validation =====
  def email_activate
    self.email_confirmed = true
    save!(validate: false)
  rescue StandardError
    false
  end

  def self.find_by_email(email)
    User.where(email:)
  rescue StandardError
    false
  end

  # ============= Searching email =====================
  def self.search_email(req)
    where('email iLIKE ?', req).limit(10)
                               .map { |user| { id: user.id, user: user.email } }
  end

  def email_token_verification(token)
    token = token['email_activation']
    if token.nil?
      false
    elsif email_token_decode(token)
      email_token_decode(token)
    end
  rescue JWT::VerificationError, JWT::DecodeError
    false
  end

  def email_token_decode(token)
    JWT.decode(token, ENV['SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  # ============================================== NEW ATTR ===========================================
  def new_attributes
    { id:, name:, email:, refres_token: }
  end


  def profile_attr
    { id:, name:, email: }
  end


  def register_atribute
    { id:, name:, email: }
  end

  def generate_password_reset_token
    payload = { email: email }
    token = JsonWebToken.encode_reset_confirm(payload)
    self.reset_password_token = token
    self.reset_password_token_expires_at = 10.minutes.from_now
    save
  end

  def forgot_att
    { id:, email:, reset_password_token:, reset_password_token_expires_at: }
  end

  
  
  private

  # def delete_projects_as_po
    
  #   # projects.where(members: { role: 'po' })
  #   # projects.destroy_all
  # end

  def self.set_profile(data)
    Profile.create(user_id: data, img_url: '')
  end

  def confirmation_token
    return unless confirm_token.blank?

    self.confirm_token = SecureRandom.urlsafe_base64.to_s
  end


end
