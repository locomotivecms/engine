require 'locomotive/steam'
require 'locomotive/steam/server'

Locomotive::Steam.configure do |config|

  # Serving assets is Rails / Nginx job, not embedded Steam's
  config.serve_assets = false

  # Dragonfly instance embedded in Steam needs a secret key
  config.image_resizer_secret = Locomotive.config.steam_image_resizer_secret

  if asset_host = CarrierWave::Uploader::Base.asset_host
    config.asset_host = asset_host
  else
    config.asset_host = CarrierWave.base_host
  end

  # rely on Mongoid for the connection information
  if mongoid = Mongoid.configure.sessions[:default]
    options = mongoid[:uri] ? mongoid.slice(:uri) : mongoid.slice(:database, :hosts, :username, :password)
    config.adapter = { name: :'mongoDB' }.merge(options.symbolize_keys)
  end

  # if Steam is used inside the engine, we can rely on the Rails
  # middlewares for the session and the request.
  config.middleware.delete Rack::Lint
  config.middleware.delete Rack::Session::Moneta

  require_relative 'steam/middlewares/missing_translations'
  require_relative 'steam/middlewares/page_editing'
  require_relative 'steam/middlewares/cache'

  config.middleware.insert_after Locomotive::Steam::Middlewares::Page, Locomotive::Steam::Middlewares::Cache
  config.middleware.insert_after Locomotive::Steam::Middlewares::Page, Locomotive::Steam::Middlewares::PageEditing
  config.middleware.insert_after Locomotive::Steam::Middlewares::Page, Locomotive::Steam::Middlewares::MissingTranslations

  require_relative 'steam/services/api_entry_submission_service'
  require_relative 'steam/services/liquid_parser_with_cache_service'

  # let the Rails engine handle the "no site" error
  config.render_404_if_no_site = false

  config.services_hook = -> (services) {
    if services.request
      services.entry_submission = Locomotive::Steam::APIEntrySubmissionService.new(services.request.env['locomotive.site'], services.locale)
      services.defer(:liquid_parser) { Locomotive::Steam::LiquidParserWithCacheService.new(services.current_site, services.parent_finder, services.snippet_finder, services.locale) }
    end
  }
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  config_file = Rails.root.join('log', 'steam.log')
  config.notifier = Locomotive::Common::Logger.setup(config_file.to_s)
end
