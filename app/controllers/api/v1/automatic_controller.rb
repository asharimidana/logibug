class Api::V1::AutomaticController < ApplicationController
  before_action :authenticate_request!, only: %i[index create show update destroy scenario]
  before_action :set_api, only: %i[update destroy]
  before_action :set_version, only: %i[create]
  before_action :set_api_show, only: %i[show run_request]

  # /automatics/:version_id/req_id
  def run_request
    data = ReadApi.get_collection(@apis)
    req_data = Automatic.run_by_req(data[params[:req_id].to_i - 1])
    if req_data
      render json: { message: 'success', data: req_data }
    else
      render json: { errors: 'unprocesable entity' }, status: 422
    end
  end

  # /automatics/:version_id/:folder_id/:req_id
  # def run
  #   data = ReadApi.run_collection(@apis)
  #   params_colection = [params[:id].to_i, params[:folder_id].to_i, params[:req_id].to_i]
  #   req_data = Automatic.run_req_by_folder(data, params_colection)
  #   if req_data.present?
  #     render json: { message: 'success', data: req_data }
  #   else
  #     render json: { errors: 'unprocesable entity' }, status: 422
  #   end
  # end

  def show
    data = ReadApi.get_collection(@apis)
    return unless data.present?

    render json: { message: 'success', data: data.map { |data_i| Automatic.new_attr(data_i) } }, status: :ok
  end

  def create
    automatic = Automatic.new(automatic_params)
    if automatic.save
      render json: { message: 'creted', data: {name: automatic[:json_url], version_id: automatic['version_id']}}, status: :ok
    else
      render json: { errors: 'unprocesable entity' }, status: 422
    end
  end

  def update
    if @apis.update(automatic_params)
      render json: { message: 'Updated', data: @apis }, status: :ok
    else
      render json: { errors: 'unprocessable_entity' }, status: 422
    end
  end

  def destroy
    FileUtils.rm_rf("public/uploads/automatic/json_url/#{@apis.id}")
    if @apis.destroy
      render json: { message: 'deleted', data: @apis }, status: :ok
    else
      render json: { errors: 'unprocessable_entity' }, status: 422
    end
  end

  private

  def set_version
    @version = Version.by_id(automatic_params[:version_id].to_i, @current_user.id)
    if @version.present?
      @version
    else
      render json: { errors: 'version not found' }, status: 422
    end
  rescue StandardError
    render json: { errors: 'unprocessable entity' }, status: 422
  end

  def set_api_show
    @apis = Automatic.where(version_id: params[:id].to_i).first
    render json: { errors: 'Not found' }, status: 404 if @apis.nil?
  rescue StandardError
    render json: { errors: 'Not Found' }, status: 404
  end

  def set_api
    @apis = Automatic.find(params[:id].to_i)
    render json: { errors: 'Not found' }, status: 404 if @apis.nil?
  rescue StandardError
    render json: { errors: 'Not Found' }, status: 404
  end

  def automatic_params
    params.permit(:json_url, :version_id)
  end
end
