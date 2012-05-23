module Locomotive
  module Extensions
    module Site
      module SubdomainDomains

        def enable_subdomain_n_domains_if_multi_sites
          # puts "multi_sites? #{Locomotive.config.multi_sites?} / manage_domains? #{Locomotive.config.manage_domains?} / heroku? #{Locomotive.heroku?} / bushido? #{Locomotive.bushido?}"

          if Locomotive.config.multi_sites? || Locomotive.config.manage_domains?

            ## fields ##
            field :subdomain
            field :domains, :type => Array, :default => []

            ## indexes
            index :domains

            ## validations ##
            validates_presence_of     :subdomain
            validates_uniqueness_of   :subdomain
            validates_exclusion_of    :subdomain, :in => Locomotive.config.reserved_subdomains
            validates_format_of       :subdomain, :with => Locomotive::Regexps::SUBDOMAIN, :allow_blank => true
            validate                  :domains_must_be_valid_and_unique

            ## callbacks ##
            before_save :add_subdomain_to_domains

            ## named scopes ##
            scope :match_domain, lambda { |domain| { :any_in => { :domains => [*domain] } } }
            scope :match_domain_with_exclusion_of, lambda { |domain, site|
              { :any_in => { :domains => [*domain] }, :where => { :_id.ne => site.id } }
            }

            send :include, InstanceMethods
          end
        end

        module InstanceMethods

          def subdomain=(subdomain)
            super(subdomain.try(:downcase))
          end

          def domains=(array)
            array.reject!(&:blank?)
            array = [] if array.blank?; super(array.map(&:downcase))
          end

          def add_subdomain_to_domains
            self.domains ||= []
            (self.domains << self.full_subdomain).uniq!
          end

          def domains_without_subdomain
            (self.domains || []) - [self.full_subdomain_was] - [self.full_subdomain]
          end

          def domains_with_subdomain
            ((self.domains || []) + [self.full_subdomain]).uniq
          end

          def full_subdomain
            "#{self.subdomain}.#{Locomotive.config.domain}"
          end

          def full_subdomain_was
            "#{self.subdomain_was}.#{Locomotive.config.domain}"
          end

          protected

          def domains_must_be_valid_and_unique
            return if self.domains.empty?

            self.domains_without_subdomain.each do |domain|
              if self.class.match_domain_with_exclusion_of(domain, self).any?
                self.errors.add(:domains, :domain_taken, :value => domain)
              end

              if not domain =~ Locomotive::Regexps::DOMAIN
                self.errors.add(:domains, :invalid_domain, :value => domain)
              end
            end
          end

        end

      end
    end
  end
end
