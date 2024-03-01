class Api::V1::MembersController < ApplicationController
  before_action :authenticate_request!, only: %i[index create show update destroy]
  before_action :valid_params, :set_params, :update_member, only: %i[create]
  before_action :set_member, only: %i[show update destroy]

  before_action only: %i[update show destroy] do
    @role = Role.by_project_id(@member.project_id, @current_user.id)
    render json: { errors: 'Forbidden' }, status: :forbidden if @role.nil? || @role != 'po'
  end

  # GET all /members
  def index
    members = Member.all_by_project_id(params[:project_id].to_i, @current_user.id)
    if members.present?
      render json: { message: 'Success', data: members.map(&:new_attribute) }, status: :ok
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  rescue StandardError
    render json: { errors: 'project_id must exist ' }, status: 422
  end

  # get /members/:id
  def show
    render json: { message: 'success', data: @member.new_attribute }, status: :ok
  end

  # POST /members
  def create
    member = Member.new(@member_params)
    if member.save
      token = JsonWebToken.encode(member_id: member.id)
      MemberActivationMailer.send_token_activation(member_params[:email], token).deliver
      render json: { message: 'User successfully invited', data: member.invite_attr }, status: 201
    else
      render json: { errors: 'Error occurred while parsing request parameters' }, status: 422
    end
  end

  # GET /members/join?invite_token=data
  def invite_activation
    decode = JsonWebToken.decode_member_token(member_params[:invite_token])
    if decode.present?
      member = Member.find_by(id: decode['member_id']) # jangan lupa validasi kalau udah invite_confirmed true
      if member.update_by_token
        query = User.joins(:members).where(members: { project_id: member.project_id }).where.not(id: member.user_id)
        notification = UserJoinedProjectNotification.with(result: Member.find_by(id:member.user_id).attr_notif)                 
        notification.deliver_later(query)
        render json: { message: 'Success join to project, please login' }, status: 200
      else
        render json: { errors: 'Forbidden!' }, status: :forbidden
      end
    else
      render json: { errors: 'Forbidden!' }, status: :forbidden
    end
  end

  # PUT / PATCH /member/:id
  def update
    if member_params[:role] != 'po' && @member.update_by_role(member_params[:role])
      render json: { message: 'Role successfully Updated', data: @member.new_attribute }, status: :ok
    else
      # render json: { errors: 'unprocessable entity' }, status: 422
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  def destroy
    if @member.destroy
      render json: { message: 'Success deleted from this project', data: @member.new_attribute }, status: :ok
    else
      # render json: { errors: 'Can not delete user this project' }, status: 422
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  # ======================= private ===================
  private

  def update_member
    cek_member = member_exist
    return unless cek_member.present? && cek_member[0]['invite_confirmed'] == false
    if cek_member.update(@member_params)
      token = JsonWebToken.encode(member_id: cek_member[0][:id])
      MemberActivationMailer.send_token_activation(member_params[:email], token).deliver
      render json: { message: 'User successfully invited', data: cek_member.first.invite_attr }, status: 201
    else
      render json: { errors: 'unprocessable entity' }, status: 422
    end
  end

  def member_exist
    cek_member = Member.by_email_project(@member_params[:user_id], member_params[:project_id])
    if cek_member.present? && cek_member[0]['invite_confirmed'] == true
      render json: { errors: 'unprocessable entity' }, status: 422
    else
      cek_member
    end
  rescue StandardError
    render json: { errors: 'unprocessable entity' }, status: 422
  end

  # set parameter before invite
  def set_params
    user = User.find_by_email(member_params[:email])
    role = Role.by_name(member_params[:role])
    if user.present? && role.present?
      @member_params = { user_id: user.first.id, role_id: role.first.id, project_id: member_params[:project_id] }
    else
      render json: { errors: 'member or role is not valid' }, status: 422
    end
  rescue StandardError
    render json: { errors: 'member or role is not valid' }, status: 422
  end

  # validatin parameter
  def valid_params
    render json: { errors: 'project_id can not blank' }, status: 422 if member_params[:project_id].nil?
    if member_params[:role].nil? || member_params[:role] == 'po'
      render json: { errors: 'role must dev or qa' }, status: 422
    end
    render json: { errors: 'email can not balnk' }, status: 422 if member_params[:email].nil?
  rescue StandardError => e
    render json: { errors: e }, status: 422
  end

  def set_member
    @member = Member.find(params[:id])
  rescue StandardError
    render json: { errors: 'Access denied' }, status: 403
    nil
  end

  def member_params
    params.permit(:invite_token, :project_id, :email, :role)
  end
end
