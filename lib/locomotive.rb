require 'locomotive/version'
require 'locomotive/core_ext'
require 'locomotive/configuration'
require 'locomotive/devise'
require 'locomotive/simple_token_authentication'
require 'locomotive/logger'
require 'locomotive/simple_form'
require 'locomotive/dragonfly'
require 'locomotive/kaminari'
require 'locomotive/presentable'
require 'locomotive/mongoid'
require 'locomotive/carrierwave'
require 'locomotive/custom_fields'
require 'locomotive/action_controller'
require 'locomotive/rails'
require 'locomotive/regexps'

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
    # Devise
    mail_address = self.config.mailer_sender
    ::Devise.mailer_sender = mail_address =~ /.+@.+/ ? mail_address : "#{mail_address}@#{Locomotive.config.domain}"

    # cookies stored in mongodb (mongoid_store)
    Rails.application.config.session_store :mongoid_store, {
      key:    self.config.cookie_key,
      domain: :all
    }

    # Check for outdated Dragonfly config
    if ::Dragonfly::VERSION =~ /^0\.9\.([0-9]+)/
      Locomotive.log :error, "WARNING: Old Dragonfly config detected, image uploads might be broken. Use 'rails g locomotive:install' to get the latest configuration files."
    end

    # avoid I18n warnings
    I18n.enforce_available_locales = false
  end

  def self.log(*args)
    level   = args.size == 1 ? 'info' : args.first
    message = args.size == 1 ? args.first : args.last

    ::Locomotive::Logger.send(level.to_sym, message)
  end

  def self.mounted_on
    Rails.application.routes.named_routes[:locomotive].path.spec.to_s
  end

  protected

  def self.app_middleware
    Rails.application.middleware
  end

end
