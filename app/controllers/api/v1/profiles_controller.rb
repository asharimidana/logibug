class Api::V1::ProfilesController < ApplicationController
  before_action :authenticate_request!, only: %i[index update]
  before_action :set_profile, only: %i[update]

  def index
    profile = @current_user.profile_attr
    profile['img_url'] = Profile.profile_img(@current_user.id.to_i)
    render json: { message: 'success', data: profile }, status: :ok
  end

  # PUT /profiles/1
  def update
    name_profile = @current_user.update_attribute(:name, profile_params[:name])
    slug = @current_user.id.to_s
    upload_image = Cloudinary::Uploader.upload params[:img_url], public_id: slug
    profile_img = @profiles.update_attribute(:img_url, upload_image['url'])

    res_data = {
      id: @current_user.id,
      name: @current_user.name,
      email: @current_user.email,
      img_url: upload_image['url']
    }

    if name_profile && profile_img
      render json: { message: 'Profile success updated', data: res_data }, status: :ok
    else
      render json: { errors: 'Update profile failed' }, status: 422
    end
  rescue StandardError => e
    render json: e, status: :bad_request
  end

  private

  def set_profile
    @profiles = Profile.find_by(user_id: @current_user.id)
    return unless @profiles.nil?

    render json: { message: 'Forbidden' }, status: :forbidden
  end

  def profile_params
    params.permit(:name, :img_url)
  end
end
