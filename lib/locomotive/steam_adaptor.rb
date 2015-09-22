require 'locomotive/steam'
require 'locomotive/steam/server'

Locomotive::Steam.configure do |config|

  # asset_host or asset_path? Depends on the Carrierwave configuration
  storage = CarrierWave::Uploader::Base.storage.to_s

  if asset_host = CarrierWave::Uploader::Base.asset_host
    config.asset_host   = asset_host
    config.serve_assets = false
  elsif CarrierWave::Uploader::Base.storage_engines.invert[storage] == :file
    config.asset_path = Rails.application.root.join('public')
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

  config.middleware.insert_after Locomotive::Steam::Middlewares::Page, Locomotive::Steam::Middlewares::PageEditing
  config.middleware.insert_after Locomotive::Steam::Middlewares::Page, Locomotive::Steam::Middlewares::MissingTranslations

  require_relative 'steam/services/api_entry_submission_service'
  require_relative 'steam/services/liquid_parser_with_cache_service'

  # let the Rails engine handle the "no site" error
  config.render_404_if_no_site = false

  config.services_hook = -> (services) {
    if services.request
      services.entry_submission = Locomotive::Steam::APIEntrySubmissionService.new(services.current_site, services.locale)
      services.defer(:liquid_parser) { Locomotive::Steam::LiquidParserWithCacheService.new(services.current_site, services.parent_finder, services.snippet_finder, services.locale) }
    end
  }
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  config_file = Rails.root.join('log', 'steam.log')
  config.notifier = Locomotive::Common::Logger.setup(config_file.to_s)
end
