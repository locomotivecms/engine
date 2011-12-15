require 'bushido'
require 'locomotive/hosting/bushido/hooks'
require 'locomotive/hosting/bushido/custom_domain'
require 'locomotive/hosting/bushido/first_installation'
require 'locomotive/hosting/bushido/account_ext'
require 'locomotive/hosting/bushido/middleware'
require 'locomotive/hosting/bushido/devise'

module Locomotive
  module Hosting
    module Bushido
      module Enabler

        extend ActiveSupport::Concern

        included do
           class << self
             attr_accessor :bushido_domains
             attr_accessor :bushido_subdomain
          end
        end

        module ClassMethods

          def bushido_app_claimed?
            ENV['BUSHIDO_CLAIMED'].present? && Boolean.set(ENV['BUSHIDO_CLAIMED'])
          end

          def enable_bushido!
            self.config.domain = ENV['APP_TLD'] unless self.config.multi_sites?

            self.config.devise_modules = [:cas_authenticatable, :rememberable, :trackable]

            self.enhance_models

            self.disable_authentication_for_not_claimed_app

            self.setup_cas_client

            self.subscribe_to_events

            self.setup_smtp_settings

            self.add_middlewares

            self.tweak_ui

            self.config.delayed_job = true # force to use delayed_job

            self.bushido_domains = ::Bushido::App.domains
            self.bushido_subdomain = ::Bushido::App.subdomain
          end

          def tweak_ui
            edit_account_url = 'https://auth.bushi.do/users/edit'

            ::Admin::GlobalActionsCell.update_for(:bushido) do |menu|
              menu.modify :welcome, :url => edit_account_url
            end

            ::Admin::SettingsMenuCell.update_for(:bushido) do |menu|
              menu.modify :account, :url => edit_account_url
            end
          end

          def enhance_models
            Site.send :include, Locomotive::Hosting::Bushido::CustomDomain
            Site.send :include, Locomotive::Hosting::Bushido::FirstInstallation
            Account.send :include, Locomotive::Hosting::Bushido::AccountExt
          end

          def disable_authentication_for_not_claimed_app
            Admin::BaseController.send :include, Locomotive::Hosting::Bushido::Devise
          end

          def setup_cas_client
            ::Devise.setup do |config|
              config.cas_base_url         = 'https://auth.bushi.do/cas'
              config.cas_logout_url       = 'https://auth.bushi.do/cas/logout'
              config.cas_create_user      = false
              config.cas_username_column  = :bushido_user_id
            end

            Admin::SessionsController.class_eval do
              def new
                redirect_to admin_pages_url
              end
            end
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

          def add_middlewares
            Rails.application.config.middleware.use '::Locomotive::Hosting::Bushido::Middleware'
          end

          # manage domains

          def add_bushido_domain(name)
            Locomotive.log "[add bushido domain] #{name}"
            ::Bushido::App.add_domain(name)

            if ::Bushido::Command.last_command_successful?
              self.bushido_domains << name
            end
          end

          def remove_bushido_domain(name)
            Locomotive.log "[remove bushido domain] #{name}"
            ::Bushido::App.remove_domain(name)

            if ::Bushido::Command.last_command_successful?
              self.bushido_domains.delete(name)
            end
          end

          def set_bushido_subdomain(name)
            Locomotive.log "[set bushido subdomain] #{name}.bushi.do"
            ::Bushido::App.set_subdomain(name)

            if ::Bushido::Command.last_command_successful?
              self.bushido_subdomain = name
            end
          end

        end
      end
    end
  end
end
