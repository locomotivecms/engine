module Locomotive
  module Deployment
    module Bushido
      module CustomDomain

        extend ActiveSupport::Concern

        included do

          after_save :add_bushido_domains
          after_destroy :remove_bushido_domains

          alias_method_chain :add_subdomain_to_domains, :bushido
        end

        module InstanceMethods

          protected

          def add_subdomain_to_domains_with_bushido
            unless self.domains_change.nil?
              full_subdomain = "#{self.subdomain}.#{Locomotive.config.default_domain}"
              @bushido_domains_change = {
                :added    => self.domains_change.last - self.domains_change.first - [full_subdomain],
                :removed  => self.domains_change.first - self.domains_change.last - [full_subdomain]
              }
            end

            add_subdomain_to_domains_without_bushido
          end

          def add_bushido_domains
            return if @bushido_domains_change.nil?

            @bushido_domains_change[:added].each do |name|
              Locomotive.add_bushido_domain(name)
            end
            @bushido_domains_change[:removed].each do |name|
              Locomotive.remove_bushido_domain(name)
            end
          end

          def remove_bushido_domains
            self.domains_without_subdomain.each do |name|
              Locomotive.remove_bushido_domain(name)
            end
          end

        end

      end
    end
  end
end