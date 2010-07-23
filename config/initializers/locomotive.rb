require File.dirname(__FILE__) + '/../../lib/locomotive.rb'
require File.dirname(__FILE__) + '/../../lib/core_ext.rb'

Locomotive.configure do |config|
  # if not defined, locomotive will use example.com as main domain name. Remove prefix www from your domain name.
  # Ex:
  # config.default_domain = Rails.env.production? ? 'mydomain.com' : 'example.com'
  config.default_domain = 'example.com'

  # configure how many items we display in sub menu in the "Contents" section.
  config.lastest_items_nb = 5

  # tell if logs are enabled. Useful for debug purpose.
  config.enable_logs = true

  # tell if the application is hosted on Heroku.
  # Locomotive uses heroku api to add / remove domains.
  # there are 2 ways of passing heroku credentials to Locomotive
  #   - from ENV variables: HEROKU_LOGIN & HEROKU_PASSWORD
  #   - from this file
  #
  # Notes:
  #   - IMPORTANT: behaviours related to this option will only be applied in production
  #   - credentials coming from this file take precedence over ENV variables
  #
  # Ex:
  # config.heroku = { :name => '<my heroku app name>', :login => 'john@doe.net', :password => 'easy' }
  config.heroku = false
end
