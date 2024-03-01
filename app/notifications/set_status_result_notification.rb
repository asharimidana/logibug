# To deliver this notification:
#
# SetStatusResultNotification.with(result: @result).deliver_later(current_user)
# SetStatusResultNotification.with(result: @result).deliver(current_user)

class SetStatusResultNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  # param :changed_by, result

  # Define helper methods to make rendering easier.
  #
  # def message
  #   t(".message")
  # end
  #
  # def url
  #   post_path(params[:post])
  # end
end
