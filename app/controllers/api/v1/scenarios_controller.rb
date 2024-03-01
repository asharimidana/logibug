class Api::V1::ScenariosController < ApplicationController
  before_action :authenticate_request!, only: %i[index create show update destroy]
  before_action :set_scenario, only: %i[show update destroy]
  before_action only: %i[create] do
    cek_skenario = Scenario.find_by_project_id(
      project_id = params_scenario[:project_id],
      user_id = @current_user.id
    )
    if cek_skenario.present?
      render json: { errors: 'Access denied' }, status: 403 if cek_skenario == 'dev'
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  before_action only: %i[update destroy] do
    cek_role = Scenario.po_qa?(params[:id].to_i, @current_user.id)
    # binding.pry
    if cek_role.present?
      render json: { errors: 'Access denied' }, status: 403 if cek_role == 'dev'
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  # /GET/scenario
  def index
    @scenarios = Scenario.all_by_project_id(
      project_id = params[:project_id].to_i,
      user_id = @current_user.id
    )
    if @scenarios.present?
      render json: { message: 'success', data: @scenarios.map { |scenario| scenario.new_attributes } }, status: :ok
    else
      render json: { errors: 'Scenario Not Found' }, status: :not_found
    end
  rescue StandardError
    render json: { errors: 'Scenario Not Found' }, status: 404
  end

  # /GET/scenario/id
  def show
    render json: { message: 'success', data: @cek_skenario.first.new_attributes }, status: :ok
  end

  # render json: { message: 'success', data: @scenarios.new_attributes }, status: :ok

  # /POST/scenario
  def create
    @scenarios = Scenario.create(set_params_post_scenario)
    if @scenarios.valid?
      render json: { message: 'Scenario successfully Created', data: @scenarios.new_attributes }, status: :created
    else
      render json: { message: @scenarios.errors }, status: :unprocessable_entity
    end
  end

  # DELETE/scenario/id
  def destroy
    @scenario = @cek_skenario[0]
    if @scenario.destroy
      render json: { message: 'Scenario successfully Deleted', data: @scenario.new_attributes }, status: :ok
    else
      render json: { message: @scenario.errors }, status: :unprocessable_entity
    end
  end

  # PUT/scenario/id
  def update
    if @cek_skenario.update(set_params_post_scenario)
      render json: { message: 'Scenario successfully updated', data: @cek_skenario.last.new_attributes }, status: :ok
    else
      render json: @cek_skenario.errors, status: :unprocessable_entity
    end
  end

  # private

  # Parameter
  def set_params_scenarios
    @scenarios = Scenario.find(params[:id])
    return render json: { message: 'Id Scenario Not Found' }, status: :not_found if @scenarios.nil?
  end

  def set_scenario
    @cek_skenario = Scenario.by_id(params[:id].to_i, @current_user.id)
    if @cek_skenario.present?
      @cek_skenario
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  # Parameter Create
  def set_params_post_scenario
    params.require(:scenario).permit(:project_id, :name)
  end

  def params_scenario
    params.require(:scenario).permit(:id, :project_id)
  end
end
