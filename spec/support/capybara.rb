require 'selenium-webdriver'

Capybara.server = :puma
Capybara.disable_animation = true # CSS transitions shift click coordinates in headless Chrome
Capybara.app_host = 'http://locomotive.local'
Capybara.server_host = '0.0.0.0'
Capybara.server_port = 9886
Capybara.default_max_wait_time = 10

Capybara.register_driver(:locomotive_headless_chrome) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: [
      'headless=new', 'disable-gpu', 'no-sandbox', 'window-size=1600,768',
      # locomotive.local is not in /etc/hosts on every machine
      'host-resolver-rules=MAP locomotive.local 127.0.0.1',
      # the Capybara server speaks plain http
      'disable-features=HttpsUpgrades'
    ]
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Stop endless errors like
# ~/.rvm/gems/ruby-1.9.2-p0@global/gems/rack-1.2.1/lib/rack/utils.rb:16:
# warning: regexp match /.../n against to UTF-8 string
# more information here: https://github.com/jnicklas/capybara/issues/243
$VERBOSE = nil
