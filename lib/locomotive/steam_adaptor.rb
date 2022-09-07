require 'locomotive/steam'
require 'locomotive/steam/server'

Locomotive::Steam.configure do |config|

  # Serving assets is Rails / Nginx job, not embedded Steam's
  config.serve_assets = false

  # Dragonfly instance embedded in Steam needs a secret key
  config.image_resizer_secret = Locomotive.config.steam_image_resizer_secret

  if asset_host = CarrierWave::Uploader::Base.asset_host # CDN?
    config.asset_host = asset_host
  elsif asset_host = CarrierWave.base_host # Example: AWS S3 / Google Cloud storage
    config.asset_host = asset_host.ends_with?('/') ? asset_host : "#{asset_host}/"
  else # Example: File storage
    config.asset_path = Rails.root.join('public').to_s
  end

  # rely on Mongoid for the connection information
  if mongoid = Mongoid.configure.clients[:default]
    options = mongoid[:uri] ? mongoid.slice(:uri) : mongoid.slice(:hosts, :database)
    options.merge!(mongoid[:options].symbolize_keys) if mongoid[:options]
    config.adapter = { name: :'mongoDB' }.merge(options.symbolize_keys)
  end

  # if Steam is used inside the engine, we can rely on the Rails
  # middlewares for the session and the request.
  config.middleware.delete Rack::Lint
  config.middleware.delete Rack::Session::Moneta

  require_relative 'steam/middlewares/catch_error'
  config.middleware.insert_after Locomotive::Steam::Middlewares::Site, Locomotive::Steam::Middlewares::CatchError

  %w(page_editing missing_translations wysihtml_css).each do |name|
    require_relative "steam/middlewares/#{name}"
    config.middleware.insert_after Locomotive::Steam::Middlewares::Page, Locomotive::Steam::Middlewares.const_get(name.camelize)
  end

  %w(api_content_entry api_entry_submission liquid_parser_with_cache async_email).each do |name|
    require_relative "steam/services/#{name}_service"
  end

  # let the Rails engine handle the "no site" error
  config.render_404_if_no_site = false

  # setup the logger
  config.log_file = Locomotive.config.steam_log_file || ENV['LOCOMOTIVE_STEAM_LOG'] || Rails.root.join('log', 'steam.log')
  config.log_level = Locomotive.config.steam_log_level

  config.services_hook = -> (services) {
    services.cache  = Rails.cache
    repositories    = services.repositories

    if services.request
      services.defer(:content_entry) { Locomotive::Steam::APIContentEntryService.new(repositories.content_type, repositories.content_entry, services.locale, services.request) }
      services.defer(:entry_submission) { Locomotive::Steam::APIEntrySubmissionService.new(services.content_entry, services.request) }
      services.defer(:liquid_parser) { Locomotive::Steam::LiquidParserWithCacheService.new(services.current_site, services.parent_finder, services.snippet_finder, services.locale) }
      services.defer(:email) { Locomotive::Steam::AsyncEmailService.new(services.page_finder, services.liquid_parser, services.asset_host, services.configuration.mode == :test) }
    end
  }
end

# Locomotive::Common.reset
# Locomotive::Common.configure do |config|
#   config_file = ENV['LOCOMOTIVE_STEAM_LOG'] || Rails.root.join('log', 'steam.log')
#   config.notifier = Locomotive::Common::Logger.setup(config_file.to_s, )
# end
