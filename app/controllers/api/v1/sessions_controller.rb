class Api::V1::SessionsController < ApplicationController
  before_action :set_email, only: %i[login]
  before_action :authenticate_request!, only: %i[logout]

  # POST /login
  def login
    payload = { user_id: @users.id }
    access_token = token_encode(payload, 2 * 60 * 60)
    refres_token = token_encode(payload, 24 * 3600 * 2)
    exp = Time.now.to_i + 5 * 60
    token_update = update_refresh_token(refres_token)
    if @users && user_auth && token_update

      # response.set_cookie(
      #   :access_token,
      #   {
      #     value: access_token,
      #     expires: 10.minute.from_now,
      #     path: '/api',
      #     httponly: true
      #   }
      # )
      # response.set_cookie(
      #   :refres_token,
      #   {
      #     value: refres_token,
      #     expires: (60 * 24).minute.from_now,
      #     path: '/api',
      #     httponly: true
      #   }
      # )
      render json: { message: 'Success login', data: @users.register_atribute, access_token:, exp:, refres_token:  }, status: :ok
    else
      render json: { errors: 'Invalid username or password' }, status: :unprocessable_entity
    end
  end

  # POST /logout
  def logout
    if @current_user.update_attribute(:refres_token, '')
      render json: { message: 'logout success' }, status: 200
    else
      render json: { errors: 'Error, please login!' }, status: :forbidden
    end
  end

  private

  def user_auth
    @users.authenticate_password(user_params[:password])
  end

  def update_refresh_token(token)
    @users.update_attribute(:refres_token, token) ? true : false
  end

  def set_email
    @users = User.find_by(email: user_params['email'])
    return unless @users.nil? || @users.email_confirmed == false
    render json: { errorr: 'Access denied' }, status: 403
  end

  def user_params
    params.permit(:email, :password)
  end
end
