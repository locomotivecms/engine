# Custom code if Locomotive is running on the Heroku platform

if Rails.env.production? && api_key = ENV['HEROKU_API_KEY'] && app_name = ENV['HEROKU_APP_NAME']
  Rails.logger.info "[Locomotive] Heroku app detected"

  require 'platform-api'

  heroku = PlatformAPI.connect(api_key)

  ActiveSupport::Notifications.subscribe('locomotive.site.domain_sync') do |name, start, finish, id, payload|
    (payload[:added] || []).each do |domain|
      heroku.domain.create(app_name, hostname: domain)
    end

    (payload[:removed] || []).each do |domain|
      heroku.domain.delete(app_name, domain)
    end
  end
end
