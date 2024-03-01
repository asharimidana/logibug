class UserNotifierMailer < ApplicationMailer
  # email asal bebas diberi nama apa saja
  default from: 'help@lapakampus.com'

  def send_signup_email(user, verify_token)
    @user = user
    @verify_token = verify_token
    @url_host = ENV['URL_HOST']
    mail(to: @user.email, subject: 'Thanks for signing up for our amazing app')
  end
end
