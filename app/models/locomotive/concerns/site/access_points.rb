module Locomotive
  module Concerns
    module Site
      module AccessPoints

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :handle
          field :domains, type: Array, default: []
          field :redirect_to_first_domain, type: Boolean, default: false
          field :redirect_to_https, type: Boolean, default: false

          ## indexes ##
          index domains: 1

          ## validations ##
          validates_presence_of     :handle
          validates_uniqueness_of   :handle
          validates_exclusion_of    :handle, in: Locomotive.config.reserved_site_handles
          validates_format_of       :handle, with: Locomotive::Regexps::HANDLE, allow_blank: true,
            multiline: true
          validate                  :domains_must_be_valid_and_unique
          validate                  :domains_must_not_be_reserved

          ## callbacks ##
          before_validation :prepare_domain_sync
          after_save        :emit_domain_sync_event
          after_destroy     :emit_domain_deletion_event

          ## named scopes ##
          scope :match_domain, ->(domain) { any_in(domains: [*domain]) }
          scope :match_domain_with_exclusion_of, ->(domain, site) {
            any_in(domains: [*domain]).where(:_id.ne => site.id)
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

        def prepare_domain_sync
          previous_domains  = self.domains_was || []
          @added_domains    = self.domains - previous_domains
          @removed_domains  = previous_domains - self.domains
        end

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

        def domains_must_not_be_reserved
          return if self.domains.empty? || Locomotive.config.reserved_domains.blank?

          self.domains.each do |domain|
            any = Locomotive.config.reserved_domains.any? do |matcher|
              matcher.is_a?(Regexp) ? domain =~ matcher : matcher == domain
            end

            self.errors.add(:domains, :domain_taken, value: domain) if any
          end
        end

        def emit_domain_sync_event
          return if @added_domains.blank? && @removed_domains.blank?

          ActiveSupport::Notifications.instrument 'locomotive.site.domain_sync', {
            added:    @added_domains,
            removed:  @removed_domains
          }
        end

        def emit_domain_deletion_event
          return if self.domains.empty?

          ActiveSupport::Notifications.instrument 'locomotive.site.domain_sync', {
            removed: self.domains
          }
        end

      end
    end
  end
end
