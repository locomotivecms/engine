Locomotive.configure do |config|

  # enable it if you want Locomotive to render the site of the Rails application embedding the engine
  # config.host = 'mylocomotiveapp.com'

  # list of forbidden handles for a site because there are in conflicts with internal resources.
  # config.reserved_site_handles = %w(sites my_account password sign_in sign_out)

  # list of domains which can't be used by any Locomotive sites
  # config.reserved_domains = []

  # configure how many items we display in sub menu in the "Models" section.
  config.ui = {
    per_page: 10
  }

  # default locale (for now, only en, de, fr, pl, pt, pt-BR, it, nl, nb, ja, cs, bg, sk, sv and uk are supported)
  config.default_locale = :en

  # locales allowed for the back-office UI
  config.locales = [:en, :fr, :de, :"zh-CN", :cs, :el, :lt, :"pt-BR", :nl, :ru]

  # available locales suggested to "localize" a site. You will have to pick up at least one among that list.
  # config.site_locales = %w{en de fr pl pt pt-BR it nl nb es ru ja cs bg sk uk}

  # tell if logs (back-office) are enabled. Useful for debug purpose.
  config.enable_logs = true

  # setup the logger for Steam (rendering)
  # config.steam_log_file = ENV['LOCOMOTIVE_STEAM_LOG'] || Rails.root.join('log', 'steam.log')
  # config.steam_log_level = ::Logger::DEBUG

  # Uncomment this line to force Locomotive to redirect all requests in the
  # back-office to https in production.
  # config.enable_admin_ssl = Rails.env.production?

  # Configure the sender for account emails and site notifications that use the
  # application's mail delivery method.
  # Use a full email address; a display name is allowed.
  config.mailer_sender = 'support@example.com'

  # Set to false to require site-specific SMTP settings for site notifications.
  # config.allow_site_notifications_via_application_delivery_method = true

  # Add the checksum of a theme asset at the end of its path to allow public caching.
  # By default, it's disabled.
  #
  # config.theme_assets_checksum = true

  # Rack-cache settings, mainly used for the inline resizing image module. Default options:
  # config.rack_cache = {
  #   verbose:     true,
  #   metastore:   URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
  #   entitystore: URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
  # }
  # If you do want to disable it for good, just use the following syntax
  # config.rack_cache = false
  #
  # Note: by default, rack/cache is disabled in the Heroku platform

  # Dragonfly within Steam uses it to generate the protective SHA
  # config.steam_image_resizer_secret = 'please change it'

  # Indicate whether you want to allow users to register with the site. If set
  # to false the registration page will not be shown. (Default: true)
  # config.enable_registration = true
end
