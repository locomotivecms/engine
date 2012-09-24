Locomotive.configure do |config|

  # A single locomotiveCMS instance can serve one single site or many.
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

  # configure how many items we display in sub menu in the "Contents" section.
  # config.ui = {
  #   :latest_entries_nb => 5,
  #   :max_content_types  => 4
  # }

  # default locale (for now, only en, de, fr, pt-BR, it and nb are supported)
  config.default_locale = :en

  # available locales suggested to "localize" a site. You will have to pick up at least one among that list.
  # config.site_locales = %w{en de fr pt-BR it nl nb es ru}

  # tell if logs are enabled. Useful for debug purpose.
  config.enable_logs = true

  # configure the e-mail address which will be shown in the DeviseMailer, NotificationMailer, ...etc
  # if you do not put the domain name in the email, LocomotiveCMS will take the default domain name depending
  # on your deployment target (server, Heroku, Bushido, ...etc)
  #
  # Ex:
  # config.mailer_sender = 'support@example.com'
  # # => 'support@heroku.com' (Heroku), 'support@bushi.do' (Bushido), 'support@example.com' (Dev) or 'support@<your_hosting_platform>' (Multi-sites)
  config.mailer_sender = 'support@example.com'

  # allow apps using the engine to add their own Liquid drops, variables and similar available
  # in Liquid templates, extending the assigns used while rendering.
  # follow the Dependency Injection pattern
  # config.context_assign_extensions = {}

  # add extra classes other than the defined content types among a site which will potentially used by the templatized pages.
  # config.models_for_templatization = %w(Product)

  # "Public" forms can be protected from Cross-Site Request Forgery (CSRF) attacks.
  # By default, that protection is disabled (false) in order to keep backwards compatibility with the existing public forms.
  #
  # Note: we strongly recommend to enable it. See the documentation about the "csrf_param" liquid tag.
  #
  # config.csrf_protection = true

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
