class Api::V1::GetAccessTokenController < ApplicationController
  before_action :authenticate_request!, only: %i[token]
  def token
    payload = { user_id: @current_user.id }
    access_token = token_encode(payload, 5 * 60)
    exp = @auth_token[0]['exp']
    if @current_user
      render json: { access_token:, exp: }, status: :ok
    else
      render json: 'forbinddern', status: :unprocessable_entity
    end
  end
end
