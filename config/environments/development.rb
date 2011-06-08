Locomotive::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log

  # config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  # MockSmtp settings
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address => "localhost",
    :port => 1025,
    :domain => "example.com"
  }

  # set up the bushido stub (uncomment it)
  # config.bushido_stub_env = false
  # config.bushido_stub_env = {
  #   'APP_TLD'               => 'bushi.do',
  #   'BUSHIDO_APP'           => 'san_francisco',
  #   'BUSHIDO_HOST'          => 'bushi.do',
  #   'LOCOMOTIVE_SITE_NAME'  => 'Locomotive TEST',
  #   'BUSHIDO_CLAIMED'       => 'true',
  #   'BUSHIDO_METRICS_TOKEN' => 'foobar'
  # }
end