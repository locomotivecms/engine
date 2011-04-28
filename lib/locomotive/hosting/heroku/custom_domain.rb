module Locomotive
  module Hosting
    module Heroku
      module CustomDomain

        extend ActiveSupport::Concern

        included do
          after_save :add_heroku_domains
          after_destroy :remove_heroku_domains

          alias_method_chain :add_subdomain_to_domains, :heroku
        end

        module InstanceMethods

          protected

          def add_subdomain_to_domains_with_heroku
            unless self.domains_change.nil?
              @heroku_domains_change = {
                :added    => self.domains_change.last - self.domains_change.first - [self.full_subdomain_was] - [self.full_subdomain],
                :removed  => self.domains_change.first - self.domains_change.last - [self.full_subdomain_was] - [self.full_subdomain]
              }
            end

            add_subdomain_to_domains_without_heroku
          end

          def add_heroku_domains
            return if @heroku_domains_change.nil?

            @heroku_domains_change[:added].each do |name|
              Locomotive.add_heroku_domain(name)
            end
            @heroku_domains_change[:removed].each do |name|
              Locomotive.remove_heroku_domain(name)
            end
          end

          def remove_heroku_domains
            self.domains_without_subdomain.each do |name|
              Locomotive.remove_heroku_domain(name)
            end
          end

        end

      end
    end
  end
end