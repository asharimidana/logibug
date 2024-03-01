class Api::V1::RolesController < ApplicationController
  before_action :authenticate_request!, only: %i[index]
  # before_action :set_role, only: %i[destroy]
  def index
    role = Role.all_by_project_id(role_params[:project_id], @current_user.id)
    if role.present?
      render json: { message: 'Success', data: role.first.new_attr_role}, status: :ok
    else
      render json: { errors: 'data not found' }, status: 404
    end
  end

  def create
    role = Role.new(role_params)
    if role.save
      render json: { data: role }, status: :created
    else
      render json: 'Can not proccess data!', status: :unprocessable_entity
    end
  end

  def role_params
    params.permit(:project_id, :name)
  end
end
