# Custom code if Locomotive is running on the Heroku platform

if Rails.env.production? && (api_key = ENV['HEROKU_API_KEY']) && (app_name = ENV['HEROKU_APP_NAME'])
  Rails.logger.info "[Locomotive] Heroku app detected"

  require 'platform-api'

  heroku = PlatformAPI.connect(api_key)

  ActiveSupport::Notifications.subscribe('locomotive.site.domain_sync') do |name, start, finish, id, payload|
    (payload[:added] || []).each do |domain|
      next if Locomotive.config.host == domain
      begin
        heroku.domain.create(app_name, hostname: domain)
      rescue Exception => e
        Rails.logger.error "Unable to add '#{domain}' as a new domain in Heroku, error #{e.message}"
      end
    end

    (payload[:removed] || []).each do |domain|
      next if Locomotive.config.host == domain
      begin
        heroku.domain.delete(app_name, domain)
      rescue Exception => e
        Rails.logger.error "Unable to remove '#{domain}' from the list of domains in Heroku, error #{e.message}"
      end
    end
  end
end
