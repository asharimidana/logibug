class ApplicationController < ActionController::API
  include AuthorizationUserId
  include MemberAuthorization
  include JsonWebToken
  include ReadApi

  attr_reader :current_user, :file, :auth_token

  # before_filter :handle_cookies
  # def handle_cookies
  #   @ashari = cookies[:access_token]
  # end

  # include RegVerification
  # def latihan
  #   xxxx = RegVerification.helo_test
  #   render json: xxxx
  # end

  def token_encode(payload_data, time_exp)
    exp = Time.now.to_i + time_exp
    payload_data[:exp] = exp
    encode_token(payload_data)
  end

  def encode_token(payload)
    JWT.encode payload, ENV['SECRET_KEY'], 'HS256'
  end

  def decode_token(payload)
    JWT.decode(payload, ENV['SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  protected

  def read_notification
    @file = JSON.parse(File.read("#{Rails.root}/public/helpers/event.json"))
  end

  def authorization!
    # pengecekan dari role terkecil
    ability = Ability.new(@current_user)
    return if ability.can? :read, Book
    (ability.can? :manage, :all) ? return : (render json: 'Forbidden!!', status: :forbidden)
  end

  def authenticate_request!
    unless user_id_in_token?
      render json: { errors: ['Not Authenticated'] }, status: :unauthorized
      return
    end
    @current_user = User.find(auth_token[0]['user_id'])
  rescue JWT::VerificationError, JWT::DecodeError, ActiveRecord::RecordNotFound
    render json: { errors: ['Forbidden'] }, status: :forbidden
  end

  private

  def http_token
    @http_token ||=
      (request.headers['Authorization'].split(' ').last if request.headers['Authorization'].present?)
  end

  def auth_token
    @auth_token ||=
      JWT.decode(http_token, ENV['SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  def user_id_in_token?
    http_token && auth_token
  end

  def member_activation
    render json: :ok
    nil
    # @current_user = JsonWebToken::AuthorizeApiRequest.call(request.headers).result
    # render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
