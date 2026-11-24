source 'https://rubygems.org'

gemspec

gem 'custom_fields',       github: 'dahogenelst/custom_fields', branch: 'master'
gem 'locomotivecms_steam', github: 'dahogenelst/steam',         branch: 'master', require: false
gem 'locomotivecms_common', github: 'dahogenelst/common',       branch: 'master', require: false
# shortcut: Rails 8 support is only on master (unreleased since 1.18.1), switch back to rubygems once released
gem 'simple_token_authentication', github: 'gonzalo-bulnes/simple_token_authentication', ref: 'f1cba4e3e6'

gem 'abbrev'

group :development do
  gem 'debug', '~> 1.9'
  gem 'web-console', '~> 4.2'
end

group :development, :test do 
  gem 'puma'
  gem 'rspec-rails'
  gem 'capybara', '~> 3.40'

  # gem 'custom_fields', path: '../custom_fields' # for Developers

  # gem 'locomotivecms_common', path: '../common', require: false
  # gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '054505c', require: false

  # gem 'locomotivecms_steam', path: '../steam', require: false
end

group :test do
  gem 'selenium-webdriver', '4.10'
  gem 'webdrivers', '~> 5.3'
  gem 'shoulda-matchers', '~> 5.3'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'json_spec', '~> 1.1'
  gem 'database_cleaner-mongoid', '~> 2.0'
  gem 'rails-controller-testing'
  gem 'email_spec', '~> 2.2'
  gem 'simplecov', require: false
end