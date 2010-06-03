# require 'locomotive/patches'
require 'locomotive/configuration'
require 'locomotive/liquid'
require 'locomotive/mongoid'

module Locomotive
  
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
    
    ActionMailer::Base.default_url_options[:host] = Locomotive.config.default_domain + (Rails.env.development? ? ':3000' : '')

    Rails.application.config.session_store :cookie_store, {
      :key => Locomotive.config.cookie_key,
      :domain => ".#{Locomotive.config.default_domain}"
    }
  end
    
end