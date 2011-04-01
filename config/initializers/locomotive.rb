require File.dirname(__FILE__) + '/../../lib/locomotive.rb'
# require_or_load 'extensions/site/subdomain_domains'

Locomotive.configure do |config|

  # A single locomotive instance can serve one single site or many.
  # If you want to run many different websites, you will have to specify
  # your own domain name (ex: locomotivehosting.com).
  #
  # Ex:
  config.multi_sites do |multi_sites|
    # each new website you add will have a default entry based on a subdomain
    # and the multi_site_domain value (ex: website_1.locomotivehosting.com).
    multi_sites.domain = 'example.com' #'myhostingplatform.com'

    # define the reserved subdomains
    # Ex:
    multi_sites.reserved_subdomains = %w(www admin email blog webmail mail support help site sites)
  end
  # config.multi_sites = false

  # configure the hosting target for the production environment. Locomotive can be installed in:
  # - your own server
  # - Heroku (you need to create an account in this case)
  # - Bushi.do (you need to create an account in this case)
  #
  # the possible options are: server, heroku, bushido or auto (default)
  # if you select 'auto', Locomotive will look after specific ENV variables to check
  # the matching platform (Heroku and Bushido set their own ENV variable).
  #
  config.hosting = :auto

  # In case you host Locomotive in Heroku, the engine uses the heroku api to add / remove domains.
  # there are 2 ways of passing heroku credentials to Locomotive
  #   - from ENV variables: HEROKU_LOGIN & HEROKU_PASSWORD
  #   - from this file
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

  # ===================================================

  # do |deployment|
  #
  #   # the possible options are: server, heroku, bushido or auto (default)
  #   # if you select 'auto', Locomotive will look after specific ENV variables to check
  #   # the matching platform (Heroku and Bushido set their own ENV variable).
  #   deployment.target = :auto
  #
  #   # in case you select heroku, it requires your Heroku credentials in order to manage domains.
  #   # If you do not want to store the credentials here, you can add them directly into the Heroku ENV
  #   # (see Heroku documentation)
  #   # deployment.heroku = {
  #   #   :login      => '<your_heroku_login>'
  #   #   :password   => '<your_heroku_password>'
  #   # }
  # end
  #

  # # define the domain name used in production.cn
  # deployment.domain = 'example.com'


  # set the default domain name used in development/test. By default, 'example.com' is used.
  # config.local_domain = 'example.com'

  # Locomotive can serve one single site or many. The "many sites" option requires more constraints for
  # the domain name (see config.domain for more explanation)
  #
  # Ex:
  # config.site_mode = :single
  # or
  # config.site_mode = :many
  # config.site_mode = :single

  # if not defined, locomotive will use example.com as main domain name. Remove prefix www from your domain name.
  # Ex:
  # config.default_domain = Rails.env.production? ? 'mydomain.com' : 'example.com'
  #
  # If you use locomotive for a single site in Heroku, use "heroku.com" as default domain name.bzc,

  # tell if the application is hosted on Bushido.
  # If enabled, there's no further configuration needed.
  # Bushido will take care of eveything
  #
  # Ex:
  # config.bushido = true
  # config.bushido = ENV['HOSTING_PLATFORM'] == 'bushido'

  # Locomotive uses the DelayedJob gem for the theme import module.
  # In case you want to deploy to Heroku, you will have to pay for an extra dyno.
  # If you do not mind about importing theme without DelayedJob, disable it.
  # config.delayed_job = false
  #
  # # default locale (for now, only en, de, fr and pt-BR are supported)
  # config.default_locale = :en
  #
  # # Configure the e-mail address which will be shown in the DeviseMailer, NotificationMailer, ...etc
  # config.mailer_sender = ENV['BUSHIDO_DOMAIN'] ? "support@#{ENV['BUSHIDO_DOMAIN']}" : 'support@example.com'
end
