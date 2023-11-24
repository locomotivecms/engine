source 'https://rubygems.org'

gemspec

group :development, :test do 
  gem 'puma', '~> 6.4.0'
  gem 'rspec-rails', '~> 6.0.1'
  gem 'capybara', '~> 3.39.0'
  gem 'debug', '>= 1.0.0'
  
  gem 'custom_fields', path: '../custom_fields' # for Developers
  # gem 'custom_fields', github: 'locomotivecms/custom_fields', ref: 'ab075b1'

  gem 'locomotivecms_common', path: '../common', require: false
  # gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '4d1bd56', require: false

  gem 'locomotivecms_steam', path: '../steam', require: false
  # gem 'locomotivecms_steam', github: 'locomotivecms/steam', ref: 'e4be455', require: false
end

group :test do
  gem 'selenium-webdriver', '4.10'
  gem 'webdrivers', '~> 5.3.1'
  gem 'shoulda-matchers', '~> 5.3.0'
  gem 'factory_bot_rails', '~> 6.4.0'
  gem 'json_spec', '~> 1.1.5'
  gem 'database_cleaner-mongoid', '~> 2.0.1'
  gem 'rails-controller-testing'
  gem 'email_spec', '~> 2.2.1'
  gem 'simplecov', require: false
end