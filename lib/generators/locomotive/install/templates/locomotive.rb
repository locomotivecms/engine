Locomotive.configure do |config|

  # A single locomotive instance can serve one single site or many.
  # If you want to run many different websites, you will have to specify
  # your own domain name (ex: locomotivehosting.com).
  #
  # Ex:
  # config.multi_sites do |multi_sites|
  #   # each new website you add will have a default entry based on a subdomain
  #   # and the multi_site_domain value (ex: website_1.locomotivehosting.com).
  #   multi_sites.domain = 'example.com' #'myhostingplatform.com'
  #
  #   # define the reserved subdomains
  #   # Ex:
  #   multi_sites.reserved_subdomains = %w(www admin email blog webmail mail support help site sites)
  # end
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
  config.hosting = :auto

  # In case you host Locomotive in Heroku, the engine uses the heroku api to add / remove domains.
  # there are 2 ways of passing heroku credentials to Locomotive
  #   - from ENV variables: HEROKU_LOGIN & HEROKU_PASSWORD
  #   - from this file, see the example below and uncomment it if needed
  # config.heroku = {
  #   :login      => '<your_heroku_login>',
  #   :password   => '<your_heroku_password>'
  # }

  # Locomotive uses the DelayedJob gem for the site import module.
  # In case you want to deploy to Heroku, you will have to pay for an extra dyno.
  # If you do not mind about importing theme without DelayedJob, disable it.
  #
  # Warning: this option is not used if you deploy on bushi.do and we set automatically the value to true.
  config.delayed_job = false

  # configure how many items we display in sub menu in the "Contents" section.
  # config.lastest_items_nb = 5

  # default locale (for now, only en, de, fr, pt-BR and it are supported)
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

  # allow apps using the engine to add their own Liquid drops, variables and similar available
  # in Liquid templates, extending the assigns used while rendering.
  # follow the Dependency Injection pattern
  # config.context_assign_extensions = {}

  # Rack-cache settings, mainly used for the inline resizing image module. Default options:
  # config.rack_cache = {
  #   :verbose     => true,
  #   :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
  #   :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
  # }
  # If you do want to disable it for good, just use the following syntax
  # config.rack_cache = false
  #
  # Note: by default, rack/cache is disabled in the Heroku platform

end