class Api::V1::ProjectsController < ApplicationController
  before_action :authenticate_request!, only: %i[create show update destroy index search]
  before_action :set_project, only: %i[show update destroy]

  before_action only: %i[update destroy] do
    cek_role = Project.po(params[:id].to_i, @current_user.id)
    if cek_role.present?
      render json: { message: 'Access denied' }, status: 403 if cek_role != 'po'
    else
      render json: { message: 'Access denied' }, status: 403
    end
  end

  # GET /projects
  def index
    @projects = Project.all_by_member_id(
      member_id = find_project[:member_id],
      user_id = @current_user.id
    )
    @projects = @projects.where('name LIKE?', "%#{params[:search]}%") if params[:search].present?
    if @projects.present?
      render json: { message: 'Success', data: @projects.map(&:project_all) }, status: :ok
    else
      render json: { message: "Upss! You don't have a project yet" }, status: 404
    end
  end

  # GET /projects/1
  def show
    render json: { message: 'Success', data: @projects[0].project_att }, status: :ok
  end

  # project /projects
  def create
    @project = Project.create(project_params)
    if @project && Member.add_member_po(@project['id'], @current_user.id)
      render json: { message: 'Project and first version successfully Created', data: @project.project_att.merge(version: @project.versions.first.version_att) },
             status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  def update
    @projects.update!(project_params)
    render json: { message: 'Project successfully updated', data: @projects.first.project_att }, status: :ok
  rescue StandardError => e
    render json: e, status: :unprocessable_entity
  end

  # DELETE /projects/1
  def destroy
    # binding.pry
    return unless @projects.first.destroy

    render json: { message: 'Project successfully deleted', data: @projects.first.project_att }, status: :ok
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @projects = Project.by_project_id(params[:id].to_i, @current_user.id)
    if @projects.present?
      @projects
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  # Only allow a trusted parameter "white list" through.
  def project_params
    params.permit(:name, :type_test, :platform)
  end

  def find_project
    params.permit(:id, :member_id)
  end
end
