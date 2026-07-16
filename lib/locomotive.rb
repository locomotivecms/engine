require 'locomotive/dependencies'
require 'locomotive/version'
require 'locomotive/core_ext'
require 'locomotive/configuration'
require 'locomotive/devise'
require 'locomotive/logger'
require 'locomotive/simple_form'
require 'locomotive/dragonfly'
require 'locomotive/kaminari'
require 'locomotive/presentable'
require 'locomotive/mongoid'
require 'locomotive/carrierwave'
require 'locomotive/custom_fields'
require 'locomotive/action_controller'
require 'locomotive/regexps'
require 'locomotive/engine'

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
    unless valid_mailer_sender?(mail_address)
      raise ArgumentError, "Locomotive.config.mailer_sender must be a full email address (got #{mail_address.inspect})"
    end
    ::Devise.mailer_sender = mail_address

    # Check for outdated Dragonfly config
    if ::Dragonfly::VERSION =~ /^0\.9\.([0-9]+)/
      Locomotive.log :error, "WARNING: Old Dragonfly config detected, image uploads might be broken. Use 'rails g locomotive:install' to get the latest configuration files."
    end

    # avoid I18n warnings
    I18n.enforce_available_locales = false
  end

  def self.valid_mailer_sender?(value)
    address = Mail::Address.new(value.to_s)
    address.address.present? && address.domain.present?
  rescue Mail::Field::ParseError
    false
  end
  private_class_method :valid_mailer_sender?

  def self.log(*args)
    level   = args.size == 1 ? 'info' : args.first
    message = args.size == 1 ? args.first : args.last

    ::Locomotive::Logger.send(level.to_sym, message)
  end

  def self.mounted_on
    Rails.application.routes.url_helpers.locomotive_path
  end

  protected

  def self.app_middleware
    Rails.application.middleware
  end

end
