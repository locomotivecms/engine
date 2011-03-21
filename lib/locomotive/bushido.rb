require 'bushido'
require 'locomotive/bushido/custom_domain'

module Locomotive
  module Bushido

    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :bushido_domains
      end
    end

    module ClassMethods

      def bushido?
        ENV["HOSTING_PLATFORM"] == "bushido"
      end

      def enable_bushido
        self.enhance_site_model
      end

      def enhance_site_model
        Site.send :include, Locomotive::Bushido::CustomDomain
      end

      # manage domains

      def add_bushido_domain(name)
        Locomotive.logger "[add bushido domain] #{name}"
        Bushido::Domains.add_subdomain(name)
        self.bushido_domains << name
      end

      def remove_bushido_domain(name)
        Locomotive.logger "[remove bushido domain] #{name}"
        Bushido::Domains.remove_subdomain(name)
        self.bushido_domains.delete(name)
      end

    end

  end
end
