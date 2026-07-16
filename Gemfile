source 'https://rubygems.org'

gemspec

group :development do
  gem 'debug', '~> 1.11'
  gem 'web-console', '~> 4.3.0'
  gem 'error_highlight', '>= 0.4.0'
end

group :development, :test do
  gem 'puma', '>= 8.0.2', '< 9'
  gem 'rspec-rails', '~> 8.0'
  gem 'capybara', '~> 3.40'
  gem 'rack', '~> 3.2.6'

  # gem 'custom_fields', path: '../custom_fields' # for Developers
  # gem 'custom_fields', github: 'locomotivecms/custom_fields', ref: '85e9c1a03c'
  gem 'custom_fields', path: '../custom_fields'

  # gem 'locomotivecms_common', path: '../common', require: false
  # gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '054505c', require: false
  gem 'locomotivecms_common', path: '../common', require: false

  # gem 'locomotivecms_steam', path: '../steam', require: false
  # gem 'locomotivecms_steam', github: 'locomotivecms/steam', ref: '023a424', require: false
  gem 'locomotivecms_steam', path: '../steam', require: false
end

group :test do
  gem 'selenium-webdriver', '>= 4.28', '< 5'
  gem 'shoulda-matchers', '~> 8.0'
  gem 'factory_bot_rails', '~> 6.5'
  gem 'database_cleaner-mongoid', '~> 2.0.1'
  gem 'rails-controller-testing'
  gem 'email_spec', '~> 2.3'
  gem 'simplecov', '~> 1.0', require: false
end
