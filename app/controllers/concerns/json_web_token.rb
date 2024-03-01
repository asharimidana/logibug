require 'jwt'

module JsonWebToken
  MEMBER_KEY = ENV['MEMBER_KEY']

  # def self.AuthorizeApiRequest(headers = {})
  #   if headers['Authorization'].present?
  #     token = headers['Authorization'].split(' ').last
  #     decoded_auth_token = JsonWebToken.decode(token)
  #     if decoded_auth_token
  #       user = User.find(decoded_auth_token[:user_id])
  #       return user if user
  #     end
  #   end
  #   nil
  # end
  def self.rest_data(data)
    data
  end

  # ====== encode email confimatin in register =====
  def self.encode_email_confirm(payload, exp = 1.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, 'xx')
  end

  def self.decode_email_confirm(token)
    JWT.decode(token, 'xx')[0]
    # user_id = token['user_id']
  rescue StandardError, JWT::VerificationError, JWT::DecodeError
    nil
  end
  # =================================================================================

  def self.encode_reset_confirm(payload, exp = 15.minutes.from_now)
    payload[:exp] = exp.to_i

    JWT.encode(payload, 'xx')
  end

  def self.decode_reset_confirm(token)
    JWT.decode(token, 'xx')[0]
  rescue StandardError, JWT::VerificationError, JWT::DecodeError
    nil
  end

  # ===== encode decode member confirmation =====
  def self.encode(payload, exp = 6.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, MEMBER_KEY)
  end

  def self.decode_member_token(token)
    JWT.decode(token, MEMBER_KEY)[0]
  rescue StandardError, JWT::VerificationError, JWT::DecodeError
    nil
  end

  #=======================================

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new body
  rescue StandardError
    nil
  end
end
