class Api::V1::UsersController < ApplicationController
  before_action :find_user_present?, only: [:create]
  before_action :authenticate_request!, only: %i[destroy]
  before_action :set_user, only: %i[destroy]

  def index
    q = params_search['q']
    user = User.search_email("%#{q}%")
    render json: {message: 'success', data: user}, status: :ok
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save && User.set_profile(@user.id)
      UserNotifierMailer.send_signup_email(@user, @verify_token).deliver
      render json: { message: 'User created, check yor email to confirmation', data: @user.register_atribute },
             status: 201
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /user/activate?email_activation=
  def email_activation
    token = email_verification_params[:email_activation]
    email = JsonWebToken.decode_email_confirm(token)
    if email.present?
      users = User.find_by_email(email['email'])
      user_exist = user_confirmed?(users[0]['email_confirmed'])
      if user_exist
        render json: { erros: 'unprocessable_entity' }, status: 422
      elsif users[0].email_activate
        render json: { message: 'Email verified, please login' }, status: :ok
      end
    else
      render json: { erros: 'unprocessable_entity' }, status: 422
    end
  end

  def user_confirmed?(data)
    data == true
  end

  # PUT/PATCH /users
  def update; end

  # DELETE /users/1
  def destroy
    unless AuthorizationUserId.auth(@current_user, params[:id])
      render json: 'Forbidden, please login!!', status: :forbidden
      return
    end

    if @user.present?
      pa = Project.joins(:members).where(members: { role_id: Role.find_by(name:'po').id, user_id: params[:id]})
      pa.destroy_all
      @user.destroy
      render json: { data: @user.register_atribute, message: 'User success deleted' }, status: :ok
    else
      render json: { errors: @users.errors.objects.first.full_message }, status: 422
    end
  end

  

  #==========================private method==============================
  private

  # check user before create
  def find_user_present?
    @users = User.find_by_email(user_params[:email])
    @verify_token = JsonWebToken.encode_email_confirm(email: user_params[:email])
    update_user if @users.present? && (@users[0][:email_confirmed] == false)
  rescue StandardError
    render json: { erros: 'Unprocessable Entity' }, status: 422
  end

  def update_user
    if @users.update(user_params)
      UserNotifierMailer.send_signup_email(@users[0], @verify_token).deliver
      render json: { data: @users.first.register_atribute, message: 'User created, check yor email to confirmation' },
             status: :created
    else
      render json: { erros: 'Unprocessable Entity' }, status: 422
    end
  end

  def set_user
    @user = User.find_by_id(params[:id])
    render json: { errors: 'User not found' }, status: :not_found if @user.nil?
  rescue StandardError
    render json: { erros: 'Unprocessable Entity' }, status: 422
  end

  def user_params
    params.permit(:name, :notif_id, :email, :password, :password_confirmation, :confirm_token)
  end

  def email_verification_params
    params.permit(:email_activation)
  end

  def params_search
    params.permit(:q)
  end
end
