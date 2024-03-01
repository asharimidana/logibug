class Api::V1::TestCasesController < ApplicationController
  before_action :authenticate_request!, only: %i[index create show update destroy scenario]
  before_action :set_scenario, only: %i[create]
  before_action :set_version, only: %i[create]
  before_action only: %i[create] do
    cek_role = Version.po_qa?(params_test_case[:version_id], @current_user.id)
    if cek_role.present?
      render json: { errors: 'Access denied' }, status: 403 if cek_role == 'dev'
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end
  before_action :set_test_case, only: %i[update show destroy]

  before_action only: %i[update destroy] do
    cek_role = Version.po_qa?(@test_cases[0][:version_id], @current_user.id)
    if cek_role.present?
      render json: { errors: 'Access denied' }, status: 403 if cek_role == 'dev'
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end
  # ================================================================================

  def index
    @test_cases = TestCase.all_by_version_id(
      version_id = params[:version_id],
      user_id = @current_user.id
    )
    if params[:scenario_id].present? && params[:test_category].present? && params[:status].present?
      @test_cases = @test_cases.where(scenario_id: params[:scenario_id], test_category: params[:test_category])
                               .joins(:result)
                               .where(results: { status: params[:status] })
    elsif params[:scenario_id].present?
      @test_cases = @test_cases.where(scenario_id: params[:scenario_id])
    elsif params[:test_category].present?
      @test_cases = @test_cases.where(test_category: params[:test_category])
    elsif params[:status].present?
      @test_cases = @test_cases.joins(:result)
                               .where(results: { status: params[:status] })
    end

    if @test_cases.present?
      render json: { message: 'success', count: @test_cases.count, data: @test_cases.map { |test_case| test_case.new_attributes } }, status: :ok
    else
      render json: { errors: 'Test Case not found!' }, status: 404
    end
  end
  

  # /GET/test_cases/id
  def show
    render json: { message: 'success', data: @test_cases.first.new_attributes }, status: :ok
  end

  # /POST/test_cases
  def create
    @test_cases = TestCase.create(params_test_case)
    if @test_cases.valid?
      render json: { message: 'Test case successfully Created', data: @test_cases.new_attributes }, status: :created
    else
      render json: { message: @test_cases.errors }, status: :unprocessable_entity
    end
  end

  def update
    begin
      @test_cases.update!(params_test_case)
      render json: { message: 'Test case successfully Updated', data: @test_cases.first.new_attributes }, status: :ok
    rescue => exception
      render json: expectation, status: :unprocessable_entity
    end
  end

  # DELETE/test_cases/id
  def destroy
    if @test_cases[0].destroy
      render json: { message: 'Test case successfully Deleted', data: @test_cases.first.new_attributes }, status: :ok
    else
      render json: { message: @test_cases.errors }, status: :unprocessable_entity
    end
  end

  def counter_result
    user = User.find(params[:id])
    total_testcases = Testcase.joins(version: { project: :members }).where(members: { user_id: user.id }).count
    testcases_with_result = Testcase.joins(:result).where(results: { user_id: user.id }).count

    data = {
      user: user,
      total_testcases: total_testcases,
      testcases_with_result: testcases_with_result
    }

    render json: { data: data } 
      # count = Testcase.joins(:result).count
      # render json: { count: count }
    # end
  

  end

  private

  def set_scenario
    @skenario = Scenario.by_id(params_test_case[:status], @current_user.id)
    
    # binding.pry
    
    # if @skenario.present?
    #   @skenario
    # else
    #   render json: { errors: 'scenarion not found' }, status: 422
    # end
  end

  def set_version
    @version = Version.by_id(params_test_case[:version_id], @current_user.id)
    if @version.present?
      @version
    else
      render json: { errors: 'version not found' }, status: 422
    end
  rescue StandardError
    render json: { errors: 'unprocessable entity' }, status: 422
  end

  # Parameter
  def set_test_case
    @test_cases = TestCase.by_id(params[:id].to_i, @current_user.id)
    if @test_cases.present?
      @test_cases
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  # Parameter Create
  def params_test_case
    params.permit(:version_id, :scenario_id, :test_category, :pre_condition, :testcase, :test_step,
                  :expectation)
  end

  # def params_test_case
  #   params.permit(:version_id)
  # end
end
