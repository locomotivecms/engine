require 'selenium-webdriver'

Capybara.server = :puma #webrick
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