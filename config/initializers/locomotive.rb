require File.dirname(__FILE__) + '/../../lib/locomotive.rb'

Locomotive.configure do |config|

  config.multi_sites = false

  # configure the hosting target for the production environment. Locomotive can be installed in:
  # - your own server
  # - Heroku (you need to create an account in this case)
  # - Bushi.do (see the bushi.do website for more explanations)
  #
  # the possible options are: server, heroku, bushido or auto (default)
  # if you select 'auto', Locomotive will look after specific ENV variables to check
  # the matching platform (Heroku and Bushido set their own ENV variables).
  #
  config.hosting = :bushido

  # In case you host Locomotive in Heroku, the engine uses the heroku api to add / remove domains.
  # there are 2 ways of passing heroku credentials to Locomotive
  #   - from ENV variables: HEROKU_LOGIN & HEROKU_PASSWORD
  #   - from this file, see the example below and uncomment it if needed
  # config.heroku = {
  #   :login      => '<your_heroku_login>'
  #   :password   => '<your_heroku_password>'
  # }

  # Locomotive uses the DelayedJob gem for the theme import module.
  # In case you want to deploy to Heroku, you will have to pay for an extra dyno.
  # If you do not mind about importing theme without DelayedJob, disable it.
  config.delayed_job = false

  # configure how many items we display in sub menu in the "Contents" section.
  config.lastest_items_nb = 5

  # default locale (for now, only en, de, fr and pt-BR are supported)
  config.default_locale = :en

  # tell if logs are enabled. Useful for debug purpose.
  config.enable_logs = true

  # Configure the e-mail address which will be shown in the DeviseMailer, NotificationMailer, ...etc
  # if you do not put the domain name in the email, Locomotive will take the default domain name depending
  # on your deployment target (server, Heroku, Bushido, ...etc)
  #
  # Ex:
  # config.mailer_sender = 'support'
  # # => 'support@heroku.com' (Heroku), 'support@bushi.do' (Bushido), 'support@example.com' (Dev) or 'support@<your_hosting_platform>' (Multi-sites)
  config.mailer_sender = 'support'
end unless Locomotive.engine?
