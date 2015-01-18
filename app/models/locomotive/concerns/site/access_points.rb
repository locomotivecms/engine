module Locomotive
  module Concerns
    module Site
      module AccessPoints

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :handle
          field :domains, type: Array, default: []

          ## indexes ##
          index domains: 1

          ## validations ##
          validates_presence_of     :handle
          validates_uniqueness_of   :handle
          validates_exclusion_of    :handle, in: Locomotive.config.reserved_site_handles
          validates_format_of       :handle, with: Locomotive::Regexps::HANDLE, allow_blank: true,
            multiline: true
          validate                  :domains_must_be_valid_and_unique

          ## callbacks ##
          after_destroy :clear_cache_for_all_domains

          ## named scopes ##
          scope :match_domain, lambda { |domain| { any_in: { domains: [*domain] } } }
          scope :match_domain_with_exclusion_of, lambda { |domain, site|
            { any_in: { domains: [*domain] }, where: { :_id.ne => site.id } }
          }
        end

        def to_param
          self.handle.to_s
        end

        def main_domain
          domains.first
        end

        def handle=(handle)
          super(handle.try(:downcase))
        end

        def domains=(array)
          array.reject!(&:blank?)
          array = [] if array.blank?; super(array.map(&:downcase))
        end

        protected

        def domains_must_be_valid_and_unique
          return if self.domains.empty?

          self.domains.each do |domain|
            if self.class.match_domain_with_exclusion_of(domain, self).any?
              self.errors.add(:domains, :domain_taken, value: domain)
            end

            if not domain =~ Locomotive::Regexps::DOMAIN
              self.errors.add(:domains, :invalid_domain, value: domain)
            end
          end
        end

        def clear_cache_for_all_domains
          self.domains.each { |name| Rails.cache.delete(name) }
        end

      end
    end
  end
end
