# require 'locomotive/patches'
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

require 'redcloth'
require 'mongo_session_store/mongoid'

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
  end
  
  def self.logger(message)
    if Locomotive.config.enable_logs == true
      Rails.logger.info(message)
    end
  end
    
end