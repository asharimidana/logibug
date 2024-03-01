class Api::V1::PasswordController < ApplicationController
  before_action :valid_params, only: %i[reset_password]

  # POST /password/forgot
  def forgot_password
    @verify_token = JsonWebToken.encode_reset_confirm(email: params[:email])
    @user = User.find_by(email: params[:email])
    if @user
      @user.generate_password_reset_token
      PasswordMailer.send_reset_password(@user, @verify_token).deliver
      render json: {message: 'check yor email to confirmation forgot password', data: @user.forgot_att}, status: 200
    else
      render json: { error: 'User not found.' }, status: 404
    end
  end

  # POST /password/reset
  def reset_password
    token = params[:token]
    decoded_token = JsonWebToken.decode_reset_confirm(token)
    @user = User.find_by_email(email: decoded_token)
    if decoded_token.present? && email = decoded_token['email']
      @user = User.find_by(email: email)
      if @user.present? && @user.update(password_params)
        render json: { message: 'Your password was reset successfully. Please log in.' }, status: 200
      else
        render json: { error: @user&.errors&.full_messages || 'Failed to reset password.' }, status: 422
      end
    else
      render json: { error: 'Invalid token.' }, status: 422
    end
  end

  # GET /password/activate?password_activation=
  def password_activation
    token = password_verification_params[:password_activation]
    email = JsonWebToken.decode_reset_confirm(token).generate_password_reset_token
    if email.present?
      @users.User.find_by_email(email['email'])
      @users[0].email_activate
        render json: { message: 'Please change your password' }, status: :ok
    else
      render json: { error: 'unprocessable_entity' }, status: 422
    end
  end

  private

  def valid_params
    if password_params.nil?
      render json: { errors: 'Password and Password confirmation cannot blank' }, status: 422
    elsif password_params[:password].nil?
      render json: { errors: 'Password cannot blank' }, status: 422 
    end
    rescue StandardError  => e
      render json: e, status: 422
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end

  def password_verification_params
    params.permit(:password_activation)
  end 
end
