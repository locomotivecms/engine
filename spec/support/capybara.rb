require 'webdrivers'
require 'selenium-webdriver'

if chromedriver_version = ENV['CHROMEDRIVER_VERSION']
  Webdrivers::Chromedriver.required_version = chromedriver_version

  # https://www.rubydoc.info/github/titusfortner/webdrivers/master
  Webdrivers.cache_time = 86_400 # ie. 24 hours
end

Capybara.server = :webrick
Capybara.app_host = 'http://locomotive.local'
Capybara.server_host = '0.0.0.0'
Capybara.server_port = 9886
Capybara.default_max_wait_time = 10

Capybara.register_driver(:locomotive_headless_chrome) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-gpu no-sandbox window-size=1600,768]
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Stop endless errors like
# ~/.rvm/gems/ruby-1.9.2-p0@global/gems/rack-1.2.1/lib/rack/utils.rb:16:
# warning: regexp match /.../n against to UTF-8 string
# more information here: https://github.com/jnicklas/capybara/issues/243
$VERBOSE = nil
