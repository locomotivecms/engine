require 'selenium-webdriver' # Selenium Manager downloads a matching chromedriver

Capybara.server = :puma 
Capybara.app_host = 'http://locomotive.local'
Capybara.server_host = '0.0.0.0'
Capybara.server_port = 9886
Capybara.default_max_wait_time = 10

Capybara.register_driver(:locomotive_headless_chrome) do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless=new disable-gpu no-sandbox window-size=1600,768 disable-features=PasswordLeakDetection]
  )
  # Chrome's password manager / leak warning ("password" is a breached password) steals keyboard focus
  options.add_preference(:credentials_enable_service, false)
  options.add_preference(:profile, password_manager_enabled: false, password_manager_leak_detection: false)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Stop endless errors like
# ~/.rvm/gems/ruby-1.9.2-p0@global/gems/rack-1.2.1/lib/rack/utils.rb:16:
# warning: regexp match /.../n against to UTF-8 string
# more information here: https://github.com/jnicklas/capybara/issues/243
$VERBOSE = nil

# shortcut: Chrome rejects origin '*' in Storage.clearDataForOrigin, which capybara 3.40 (latest) sends on reset;
# capybara only clears cookies by default, so clear those directly. Drop once capybara ships a fix.
module ChromeResetWithoutWildcardOrigin
  def execute_cdp(cmd, params = {})
    return super unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetWithoutWildcardOrigin)

# shortcut: recent chromedriver reports a detached node as UnknownError ("does not belong to the document")
# instead of StaleElementReferenceError, so capybara does not retry it. Translate that one message.
# Drop once chromedriver/selenium map it again.
module StaleNodeAsStaleElement
  private

  def execute(*)
    super
  rescue Selenium::WebDriver::Error::UnknownError => e
    raise unless e.message.include?('does not belong to the document')

    raise Selenium::WebDriver::Error::StaleElementReferenceError, e.message
  end
end
Selenium::WebDriver::Remote::Bridge.prepend(StaleNodeAsStaleElement)
