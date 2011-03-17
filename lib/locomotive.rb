require 'mimetype_fu'
require 'devise'

require 'locomotive/version'
require 'locomotive/core_ext'
require 'locomotive/configuration'
require 'locomotive/logger'
require 'locomotive/liquid'
require 'locomotive/mongoid'
require 'locomotive/carrierwave'
require 'locomotive/heroku'
require 'locomotive/custom_fields'
require 'locomotive/httparty'
require 'locomotive/inherited_resources'
require 'locomotive/admin_responder'
require 'locomotive/routing'
require 'locomotive/regexps'
require 'locomotive/render'
require 'locomotive/import'
require 'locomotive/delayed_job'
require 'locomotive/middlewares'
require 'locomotive/session_store'

module Locomotive

  include Locomotive::Heroku

  class << self
    attr_accessor :config

    def config
      self.config = Configuration.new unless @config
      @config
    end
  end

  def self.configure
    self.config ||= Configuration.new
    yield(self.config)

    after_configure
  end

  def self.after_configure
    raise '[Error] Locomotive needs a default domain name' if Locomotive.config.default_domain.blank?

    ActionMailer::Base.default_url_options[:host] = self.config.default_domain + (Rails.env.development? ? ':3000' : '')

    # cookies stored in mongodb (mongoid_store)
    Rails.application.config.session_store :mongoid_store, {
      :key => Locomotive.config.cookie_key
    }

    # Heroku support
    self.enable_heroku if self.heroku?

    # Devise
    Devise.mailer_sender = self.config.mailer_sender

    # Load all the dynamic classes (custom fields)
    begin
      ContentType.all.collect(&:fetch_content_klass)
      AssetCollection.all.collect(&:fetch_asset_klass)
    rescue ::Mongoid::Errors::InvalidDatabase => e
      # let assume it's because of the first install (meaning no config.yml file)
    end
  end

  def self.logger(message)
    if Locomotive.config.enable_logs == true
      Rails.logger.info(message)
    end
  end

end
