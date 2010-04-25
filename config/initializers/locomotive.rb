require 'lib/locomotive.rb'
require 'lib/core_ext.rb'

Locomotive.configure do |config|
  config.default_domain = 'example.com'
end

# TODO: embed it in Locomotive right after configure
ActionMailer::Base.default_url_options[:host] = Locomotive.config.default_domain + (Rails.env.development? ? ':3000' : '')
