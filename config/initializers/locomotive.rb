require 'lib/locomotive.rb'

Locomotive.configure do |config|
  config.default_domain = 'example.com'
end

# TODO: embed it in Locomotive
ActionMailer::Base.default_url_options[:host] = Locomotive.config.default_domain + (Rails.env.development? ? ':3000' : '')