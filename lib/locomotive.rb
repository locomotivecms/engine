require 'locomotive/version'
require 'locomotive/core_ext'
require 'locomotive/configuration'
require 'locomotive/devise'
require 'locomotive/logger'
require 'locomotive/haml'
require 'locomotive/formtastic'
require 'locomotive/dragonfly'
require 'locomotive/kaminari'
require 'locomotive/liquid'
require 'locomotive/mongoid'
require 'locomotive/carrierwave'
require 'locomotive/custom_fields'
require 'locomotive/httparty'
require 'locomotive/action_controller'
require 'locomotive/rails'
require 'locomotive/routing'
require 'locomotive/regexps'
require 'locomotive/render'
require 'locomotive/middlewares'
require 'locomotive/session_store'

module Locomotive
  extend ActiveSupport::Autoload

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
    self.define_subdomain_and_domains_options

    # multi sites support
    self.configure_multi_sites

    # Devise
    mail_address = self.config.mailer_sender
    # ::Devise.mailer_sender = mail_address =~ /.+@.+/ ? mail_address : "#{mail_address}@#{Locomotive.config.domain}"

    # cookies stored in mongodb (mongoid_store)
    Rails.application.config.session_store :mongoid_store, {
      :key    => self.config.cookie_key,
      :domain => :all
    }

    # add middlewares (dragonfly, font, seo, ...etc)
    self.add_middlewares

    # Load all the dynamic classes (custom fields)
    begin
      ContentType.all.collect { |content_type| content_type.klass_with_custom_fields(:entries) }
    rescue ::Mongoid::Errors::InvalidDatabase => e
      # let assume it's because of the first install (meaning no config.yml file)
    end

    # enable the hosting solution if both we are not in test or dev and that the config.hosting option has been filled up
    self.enable_hosting
  end

  def self.add_middlewares
    self.app_middleware.insert 0, 'Dragonfly::Middleware', :images

    if self.rack_cache?
      self.app_middleware.insert_before 'Dragonfly::Middleware', '::Locomotive::Middlewares::Cache', self.config.rack_cache
    end

    self.app_middleware.insert_before Rack::Lock, '::Locomotive::Middlewares::Fonts', :path => %r{^/fonts}
    self.app_middleware.use '::Locomotive::Middlewares::SeoTrailingSlash'

    self.app_middleware.use '::Locomotive::Middlewares::InlineEditor'
  end

  def self.configure_multi_sites
    if self.config.multi_sites?
      domain_name = self.config.multi_sites.domain

      raise '[Error] Locomotive needs a domain name when used as a multi sites platform' if domain_name.blank?

      self.config.domain = domain_name
    end
  end

  def self.enable_hosting
    return if Rails.env.test? || Rails.env.development? || self.config.hosting.blank?

    target = self.config.hosting[:target]
    method = :"enable_#{target}"

    self.send(method) if self.respond_to?(method)
  end

  def self.define_subdomain_and_domains_options
    if self.config.multi_sites?
      self.config.manage_subdomain = self.config.manage_domains = true
    else
      self.config.manage_domains = self.config.manage_subdomain = false
    end
  end

  def self.log(*args)
    level   = args.size == 1 ? 'info' : args.first
    message = args.size == 1 ? args.first : args.last

    ::Locomotive::Logger.send(level.to_sym, message)
  end

  # rack_cache: needed by default
  def self.rack_cache?
    self.config.rack_cache != false
  end

  def self.mounted_on
    Rails.application.routes.named_routes[:locomotive].path.spec.to_s
  end

  protected

  def self.app_middleware
    Rails.application.middleware
  end

end
