# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  user_name:  'logibugqatros@gmail.com', 
  password:  'balblbfdncywmxrr', 
  domain:  'localhost:3000',
  address:  'smtp.gmail.com',
  port:  587,
  authentication:  :plain,
  enable_starttls_auto:  true,
  open_timeout: 5,
  read_timeout: 5
}
