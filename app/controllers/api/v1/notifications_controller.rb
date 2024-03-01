class Api::V1::NotificationsController < ApplicationController
  before_action :set_notif, only: %i[show update destroy]
  before_action :authenticate_request!, only: %i[show index mark_as_read mark_all_read]

  def index
    @notifications = @current_user.notifications.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    if @notifications.present?
      render json: {
        message: 'success', 
        total_unread: @current_user.notifications.unread.count,
        current_page: @notifications.current_page,
        total_pages: @notifications.total_pages,
        data: @notifications, 
      }
    else
      render json: { message: 'Notification not found'}, status: :not_found
    end
  end


  # def show
    
  # end

  def mark_as_read
    notifications = Notification.find(notif_params[:id])
    if notifications.unread?
      notifications.mark_as_read! 
      render json: { message: 'notification as read' } 
    end
  end

  def mark_all_read
    user = @current_user
    @notifications = user.notifications
    @notifications.mark_as_read!
    render json: { message: 'All notification as read' } 
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_notif
      @notif = Notification.find_by_id(params[:id])
      if @notif.nil?
        render json: { message: 'Notification not found' }, status: :not_found
      end
  end

  def notif_params
    params.permit(:id)
  end
end