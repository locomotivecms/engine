Capybara.configure do |config|
  config.default_selector   = :css
  config.server_port        = 9886
  config.app_host           = 'http://localhost:9886'
end

Capybara.default_wait_time = 5

Capybara.javascript_driver = :poltergeist

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 60)
end

# Stop endless errors like
# ~/.rvm/gems/ruby-1.9.2-p0@global/gems/rack-1.2.1/lib/rack/utils.rb:16:
# warning: regexp match /.../n against to UTF-8 string
# more information here: https://github.com/jnicklas/capybara/issues/243
$VERBOSE = nil
