module Locomotive
  module Hosting
    module Bushido
      module CustomDomain

        extend ActiveSupport::Concern

        included do
          validate :subdomain_availability

          before_update :check_subdomain_change

          after_save :add_bushido_domains
          after_update :record_new_subdomain
          after_destroy :remove_bushido_domains

          alias_method_chain :add_subdomain_to_domains, :bushido
        end

        module InstanceMethods

          protected

          def subdomain_availability
            return true if self.new_record? || !self.subdomain_changed?

            unless ::Bushido::App.subdomain_available?(self.subdomain)
              self.errors.add(:subdomain, :exclusion)
            end
          end

          def add_subdomain_to_domains_with_bushido
            unless self.domains_change.nil?
              @bushido_domains_change = {
                :added    => self.domains_change.last - self.domains_change.first - [self.full_subdomain_was] - [self.full_subdomain],
                :removed  => self.domains_change.first - self.domains_change.last - [self.full_subdomain_was] - [self.full_subdomain]
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

          def check_subdomain_change
            @new_bushido_subdomain = !Locomotive.config.multi_sites? && self.subdomain_changed?
            true
          end

          def record_new_subdomain
            if @new_bushido_subdomain == true
              Locomotive.set_bushido_subdomain(self.subdomain)
            end
          end

        end

      end
    end
  end
end