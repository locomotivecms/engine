require 'locomotive/steam'
require 'locomotive/steam/server'

Locomotive::Steam.configure do |config|

  # Serving assets is Rails / Nginx job, not embedded Steam's
  config.serve_assets = false

  # Dragonfly instance embedded in Steam needs a secret key
  config.image_resizer_secret = Locomotive.config.steam_image_resizer_secret

  if asset_host = CarrierWave::Uploader::Base.asset_host # CDN?
    config.asset_host = asset_host
  elsif asset_host = CarrierWave.base_host # Example: AWS storage
    config.asset_host = asset_host
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

  %w(cache catch_error page_editing missing_translations wysihtml_css).each do |name|
    require_relative "steam/middlewares/#{name}"
    config.middleware.insert_after Locomotive::Steam::Middlewares::Page, Locomotive::Steam::Middlewares.const_get(name.camelize)
  end

  require_relative 'steam/services/api_entry_submission_service'
  require_relative 'steam/services/liquid_parser_with_cache_service'

  # let the Rails engine handle the "no site" error
  config.render_404_if_no_site = false

  config.services_hook = -> (services) {
    services.cache = Rails.cache

    if services.request
      services.entry_submission = Locomotive::Steam::APIEntrySubmissionService.new(services.request.env['locomotive.site'], services.locale, services.request.ip)
      services.defer(:liquid_parser) { Locomotive::Steam::LiquidParserWithCacheService.new(services.current_site, services.parent_finder, services.snippet_finder, services.locale) }
    end
  }
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  config_file = ENV['LOCOMOTIVE_STEAM_LOG'] || Rails.root.join('log', 'steam.log')
  config.notifier = Locomotive::Common::Logger.setup(config_file.to_s)
end
