class MemberActivationMailer < ApplicationMailer
  def send_token_activation(user, verify_token)
    @email = user
    @verify_token = verify_token
    @url_host = ENV['URL_HOST']
    mail(to: @email, subject: 'Anda di undang pada project')
  end
end
