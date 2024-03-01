class PasswordMailer < ApplicationMailer
  def send_reset_password(user, verify_token)
    @user = user
    @verify_token = verify_token
    @url_host = ENV['URL_HOST']
    mail(to: @user.email, subject: 'Logibug Account Forgot Password')
  end
end