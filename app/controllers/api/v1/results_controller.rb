class Api::V1::ResultsController < ApplicationController
  before_action :authenticate_request!, only: %i[destroy logout create index update show]
  before_action :set_result, only: %i[show update destroy]
  before_action :set_test_case, only: %i[create]
  before_action only: %i[create] do
    cek_role = Result.po_qa?(result_params[:test_case_id], @current_user.id)
    if cek_role.present?
      render json: { errors: 'Access denied' }, status: 403 if cek_role == 'dev'
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  before_action only: %i[update destroy] do
    cek_role = Result.po_qa?(@results[0][:test_case_id], @current_user.id)

    if cek_role.present?
      render json: { errors: 'Access denied' }, status: 403 if cek_role == 'dev'
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  # GET /results
  def index
    # results = Result.all.map { |result| { user_name: result.user_name } }
    # render json: results
    # @results = Result.all
    # @user = current_user

    @results = Result.all_by_test_case_id(
      test_case_id = params[:test_case_id],
      user_id = @current_user.id
    )

    if @results.present?
      render json: { message: 'Success', data: @results.first.result_att }, status: :ok
    else
      render json: { message: "You haven't create any results yet" }, status: 404
    end
  end

  # GET /results/1
  def show
    render json: { message: 'Success', data: @results.first.result_att }, status: :ok
  end

  # result /results
  def create
    slug = @current_user.id.to_s
    upload_image = Cloudinary::Uploader.upload params[:img_url], public_id: "#{slug}_result"
    result = Result.create(
      {
        test_case_id: result_params[:test_case_id].to_i,
        actual: result_params[:actual],
        status: result_params[:status],
        priority: result_params[:priority],
        severity: result_params[:severity],
        img_url: upload_image['url'],
        note: result_params[:note],
        user_name: @current_user.name
      }
    )
    project_id = result.test_case.version.project_id
    if result.status == 'fail'
      notify_recipient(result.id, project_id, 1, result.status)
    else
      notify_recipient(result.id, project_id, 2, result.status)
    end

    render json: { message: 'Success', data: result }, status: :created
  rescue StandardError => e
    render json: e, status: :bad_request
  end

  # PATCH/PUT /results/1
  def update
    slug = @current_user.id.to_s
    if params[:img_url].present?
      upload_image = Cloudinary::Uploader.upload params[:img_url], public_id: "#{slug}_result"
    end

    result =
      {
        test_case_id: result_params[:test_case_id].to_i,
        actual: result_params[:actual],
        status: result_params[:status],
        priority: result_params[:priority],
        severity: result_params[:severity],
        img_url: upload_image.present? ? upload_image['url'] : result.img_url,
        note: result_params[:note]
      }

    current_status = Result.find(params[:id]).status
    test_case = TestCase.find(result_params[:test_case_id].to_i)

    if @results.update(result)
      res = Result.find(params[:id])
      project_id = test_case.version.project_id
      notify_recipient(params[:id], project_id, 3, current_status)

      render json: { message: 'Result successfully Updated', data: @results.first.result_att }, status: :ok
    else
      render json: result.errors, status: :unprocessable_entity
    end
    # rescue StandardError
    #   render json: 'can not process entity', status: :unprocessable_entity
  end

  # DELETE /results/1
  def destroy
    if @results[0].destroy
      render json: { message: 'Result successfully Deleted', data: @results.first.result_att }, status: :ok
    else
      render json: { message: @results.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_test_case
    @test_cases = TestCase.by_id(result_params[:test_case_id], @current_user.id)
    if @test_cases.present?
      @test_cases
    else
      render json: { errors: 'test case not found' }, status: 404
    end
  end

  def notify_recipient(result_id, project_id, type, current_status)
    user = User.find_by(id: @current_user.id)
    result = Result.find(result_id)
    query = User.joins(:members).where(members: { project_id: }).where.not(id: user.id)
    notification = if type == 1
                     SetStatusResultNotification.with(result: result.new_attr_create_fail(user.id))
                   elsif type == 2
                     SetStatusResultNotification.with(result: result.new_attr_create_pass(user.id))
                   else
                     UpdateResultNotification.with(result: result.new_attr_update(user.id, current_status))
                   end
    notification.deliver_later(query)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_result
    @results = Result.by_id(params[:id].to_i, @current_user.id)
    if @results.present?
      @results
    else
      render json: { errors: 'Access denied' }, status: 403
    end
  end

  # Only allow a trusted parameter "white list" through.
  def result_params
    params.permit(:test_case_id, :actual, :status, :priority, :severity, :img_url, :note, :id)
  end
end
