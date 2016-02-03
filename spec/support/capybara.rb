require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/webkit'

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end

Capybara.configure do |config|
  config.default_selector   = :css
  config.server_port        = 9886
  config.app_host           = 'http://localhost:9886'
end

Capybara.default_max_wait_time = 5
Capybara.javascript_driver = :webkit

# Stop endless errors like
# ~/.rvm/gems/ruby-1.9.2-p0@global/gems/rack-1.2.1/lib/rack/utils.rb:16:
# warning: regexp match /.../n against to UTF-8 string
# more information here: https://github.com/jnicklas/capybara/issues/243
$VERBOSE = nil
