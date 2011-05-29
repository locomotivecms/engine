require 'bushido'
require 'locomotive/hosting/bushido/custom_domain'
require 'locomotive/hosting/bushido/first_installation'
require 'locomotive/hosting/bushido/account_ext'
require 'locomotive/hosting/bushido/middleware'
require 'locomotive/hosting/bushido/devise'

module Locomotive
  module Hosting
    module Bushido

      extend ActiveSupport::Concern

      included do
         class << self
           attr_accessor :bushido_domains
           attr_accessor :bushido_subdomain
        end
      end

      module ClassMethods

        def bushido?
          self.config.hosting == :bushido ||
          (self.config.hosting == :auto && ENV['APP_TLD'] == 'bushi.do')
        end

        def bushido_app_claimed?
          ENV['BUSHIDO_CLAIMED'].present? && ENV['BUSHIDO_CLAIMED'].to_s.downcase == 'true'
        end

        def enable_bushido
          self.config.domain = ENV['APP_TLD'] unless self.config.multi_sites?

          self.enhance_models_with_bushido

          self.disable_authentication_for_not_claimed_app

          self.setup_smtp_settings

          self.add_middleware

          self.config.delayed_job = true # force to use delayed_job

          self.bushido_domains = ::Bushido::App.domains
          self.bushido_subdomain = ::Bushido::App.subdomain
        end

        def enhance_models_with_bushido
          Site.send :include, Locomotive::Hosting::Bushido::CustomDomain
          Site.send :include, Locomotive::Hosting::Bushido::FirstInstallation
          Account.send :include, Locomotive::Hosting::Bushido::AccountExt
        end

        def disable_authentication_for_not_claimed_app
          Admin::BaseController.send :include, Locomotive::Hosting::Bushido::Devise
        end

        def setup_smtp_settings
          ActionMailer::Base.delivery_method = :smtp
          ActionMailer::Base.smtp_settings = {
            :authentication         => ENV['SMTP_AUTHENTICATION'],
            :address                => ENV['SMTP_SERVER'],
            :port                   => ENV['SMTP_PORT'],
            :domain                 => ENV['SMTP_DOMAIN'],
            :user_name              => ENV['SMTP_USER'],
            :password               => ENV['SMTP_PASSWORD'],
            :enable_starttls_auto   => ENV['SMTP_TLS'].to_s == 'true'
          }
        end

        def add_middleware
          ::Locomotive::Application.configure do |config|
            config.middleware.use '::Locomotive::Hosting::Bushido::Middleware'
          end
        end

        # manage domains

        def add_bushido_domain(name)
          Locomotive.logger "[add bushido domain] #{name}"
          ::Bushido::App.add_domain(name)

          if ::Bushido::Command.last_command_successful?
            self.bushido_domains << name
          end
        end

        def remove_bushido_domain(name)
          Locomotive.logger "[remove bushido domain] #{name}"
          ::Bushido::App.remove_domain(name)

          if ::Bushido::Command.last_command_successful?
            self.bushido_domains.delete(name)
          end
        end

        def set_bushido_subdomain(name)
          Locomotive.logger "[set bushido subdomain] #{name}.bushi.do"
          ::Bushido::App.set_subdomain(name)

          if ::Bushido::Command.last_command_successful?
            self.bushido_subdomain = name
          end
        end

      end
    end
  end
end