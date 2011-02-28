Locomotive.configure do |config|
  # if not defined, locomotive will use example.com as main domain name. Remove prefix www from your domain name.
  # Ex:
  # config.default_domain = Rails.env.production? ? 'mydomain.com' : 'example.com'
  #
  # If you use locomotive for a single site in Heroku, use "heroku.com" as default domain name.
  # Your heroku app name (<app_name>.heroku.name) will be used as the sub domain name in Locomotive
  # during the installation wizzard.
  # Ex:
  # config.default_domain = Rails.env.production? ? 'heroku.com' : 'example.com'
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

  # Locomotive uses the DelayedJob gem for the theme import module.
  # In case you want to deploy to Heroku, you will have to pay for an extra dyno.
  # If you do not mind about importing theme without DelayedJob, disable it.
  config.delayed_job = false

  # default locale (for now, only en, de, fr and pt-BR are supported)
  config.default_locale = :en

  # Configure the e-mail address which will be shown in the DeviseMailer, NotificationMailer, ...etc
  config.mailer_sender = 'support@example.com'
end
