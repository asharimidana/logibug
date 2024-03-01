source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'rails', '~> 7.0.4', '>= 7.0.4.2'

gem "mysql2", "~> 0.5"
# gem 'mysql'
gem "mysql2", "~> 0.5"

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

gem 'cloudinary'
gem 'carrierwave'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'
gem 'dotenv-rails'
gem 'faker'
gem 'figaro'
gem 'jwt'

gem 'rubocop'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# ashari midana
# https://www.rubyguides.com/2019/10/scopes-in-ruby-on-rails/
# https://github.com/RolifyCommunity/rolify/wiki/Devise---CanCanCan---rolify-Tutorial
gem 'cancancan'
gem 'rack-cors'
gem 'rolify'
gem 'groupify'
group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'pry'
end

group :development do
  # gem "spring"
end
gem "dockerfile-rails", ">= 1.2", :group => :development

gem "noticed", "~> 1.6"

