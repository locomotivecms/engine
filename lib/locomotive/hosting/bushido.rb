require 'bushido'
require 'locomotive/hosting/bushido/custom_domain'

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
          (self.config.hosting == :auto && ENV['HOSTING_PLATFORM'] == 'bushido')
        end

        def enable_bushido
          self.config.domain = ENV['APP_TLD']

          self.enhance_site_model

          self.bushido_domains = ::Bushido::App.domains
          self.bushido_subdomain = ::Bushido::App.subdomain
        end

        def enhance_site_model
          Site.send :include, Extensions::Site::SubdomainDomains
          Site.send :include, Locomotive::Hosting::Bushido::CustomDomain
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