# To deliver this notification:
#
# UserJoinedProjectNotification.with(post: @post).deliver_later(current_user)
# UserJoinedProjectNotification.with(post: @post).deliver(current_user)

class UserJoinedProjectNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database, debug: true
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  # param :post

  # Define helper methods to make rendering easier.
  #
  def message
    "Testing Notification"
  end
  #
  # def url
  #   post_path(params[:post])
  # end
end
