class Api::V1::VersionsController < ApplicationController
  before_action :authenticate_request!, only: %i[index create show update destroy copy]
  before_action :set_version, only: %i[show update destroy]
  before_action only: %i[create update] do
    cek_version = Scenario.find_by_project_id(
      project_id = params_version[:project_id],
      user_id = @current_user.id
    )
    if cek_version.present?
      render json: { errors: 'Access denied' }, status: :forbidden if cek_version == 'dev'
    else
      render json: { errors: 'Access denied' }, status: :forbidden
    end
  end

  before_action only: %i[update destroy copy] do
    cek_role = Version.po_qa?(params[:id].to_i, @current_user.id)
    # binding.pry
    if cek_role.present?
      render json: { errors: 'Access denied' }, status: :forbidden if cek_role == 'dev'
    else
      render json: { errors: 'Access denied' }, status: :forbidden
    end
  end 
  
  def index
    # binding.pry
    @versions = Version.all_by_project_id(
      project_id = params[:project_id].to_i,
      user_id = @current_user.id
    )
    if @versions.present?
      render json: { message: 'success', data: @versions.map(&:version_att)} 
    else
      render json: { message: 'Version Not Found'}, status: :not_found
    end
  end

  def show
    render json: {message: 'success', data: @cek_version}, status: :ok
  rescue 
      render json: { message: 'Version Not Found'}, status: :not_found
  end

  def create
    @version = Version.new(version_params)
    if @version.save
      render json: { message: 'Version successfully Created', data: @version.version_att }, status: :created
    else
      render json: @version.errors, status: :unprocessable_entity
    end
  end

  def update
    begin
      @cek_version.update!(version_params)
      render json: { message: 'Version successfully Updated', data: @cek_version.first.version_att }, status: :ok
    rescue => exception
      render json: expectation, status: :unprocessable_entity
    end
  end

  def destroy
    @version = @cek_version[0]
    if @version.destroy
    render json: { message: 'Version successfully Deleted', data: @version.version_att }, status: :ok
    else
      render json: { message: @scenario.errors }, status: :unprocessable_entity
    end
  end


  # POST /clone/id
  def copy
    # binding.pry
    version = Version.find(params[:id])
    cloned_version = version.clone_with_testcases
    
    render json: { message: 'Version  successfully cloned', data: cloned_version.version_clone.merge(test_case: cloned_version.test_cases.first.new_attributes) }, status: :created
  end

  private
  
  def version_params
    params.permit(:name, :project_id)
  end

  def set_version
    @cek_version = Version.by_id(params[:id].to_i, @current_user.id)
    if @cek_version.present?
      @cek_version
    else
      render json: { errors: 'Access denied' }, status: :forbidden
    end
    rescue
      render json: { errors: 'Access denied' }, status: :forbidden
  end

  def params_version
    params.permit(:id, :project_id)
  end
end
