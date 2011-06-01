require 'mimetype_fu'
require 'devise'

require 'locomotive/version'
require 'locomotive/core_ext'
require 'locomotive/configuration'
require 'locomotive/logger'
require 'locomotive/liquid'
require 'locomotive/mongoid'
require 'locomotive/carrierwave'
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
require 'locomotive/hosting'

module Locomotive

  include Locomotive::Hosting::Heroku
  include Locomotive::Hosting::Bushido

  class << self
    attr_accessor :config

    def config
      self.config = Configuration.new unless @config
      @config
    end
  end

  def self.engine?
    self.const_defined?('Engine')
  end

  def self.default_site_template_present?
    File.exists?(self.default_site_template_path)
  end

  def self.default_site_template_path
    File.join(Rails.root, 'tmp/default_site_template.zip')
  end

  def self.configure
    self.config ||= Configuration.new

    yield(self.config)

    after_configure
  end

  def self.after_configure
    self.define_subdomain_and_domains_options

    # multi sites support
    self.configure_multi_sites

    # hosting platform
    self.configure_hosting

    # Devise
    mail_address = self.config.mailer_sender
    ::Devise.mailer_sender = mail_address =~ /.+@.+/ ? mail_address : "#{mail_address}@#{Locomotive.config.domain}"

    # cookies stored in mongodb (mongoid_store)
    Rails.application.config.session_store :mongoid_store, {
      :key => self.config.cookie_key
    }

    # Load all the dynamic classes (custom fields)
    begin
      ContentType.all.collect(&:fetch_content_klass)
      AssetCollection.all.collect(&:fetch_asset_klass)
    rescue ::Mongoid::Errors::InvalidDatabase => e
      # let assume it's because of the first install (meaning no config.yml file)
    end
  end

  def self.configure_multi_sites
    if self.config.multi_sites?
      domain_name = self.config.multi_sites.domain

      raise '[Error] Locomotive needs a domain name when used as a multi sites platform' if domain_name.blank?

      self.config.domain = domain_name
    end
  end

  def self.configure_hosting
    # Heroku support
    self.enable_heroku if self.heroku?

    # Bushido support
    self.enable_bushido if self.bushido?
  end

  def self.define_subdomain_and_domains_options
    if self.config.multi_sites?
      self.config.manage_subdomain = self.config.manage_domains = true
    else
      # Note: (Did) modify the code below if Locomotive handles a new hosting solution (not a perfect solution though)
      self.config.manage_domains = self.heroku? || self.bushido?
      self.config.manage_subdomain = self.bushido?
    end
  end

  def self.logger(message)
    if self.config.enable_logs == true
      Rails.logger.info(message)
    end
  end

end
