module Locomotive
  module Extensions
    module Page
      module Templatized

        extend ActiveSupport::Concern

        included do

          field :templatized, :type => Boolean, :default => false
          field :target_klass_name

          ## validations ##
          validates_presence_of :target_klass_name, :if => :templatized?
          validate              :ensure_target_klass_name_security

          ## callbacks ##
          before_validation :set_slug_if_templatized
          before_validation :ensure_target_klass_name_security

          ## scopes ##
          scope :templatized, :where => { :templatized => true }

          ## virtual attributes ##
          attr_accessor :content_entry
        end

        # Returns the class specified by the target_klass_name property
        #
        # @example
        #
        #   page.target_klass_name = 'Locomotive::Entry12345'
        #   page.target_klass = Locomotive::Entry12345
        #
        # @return [ Class ] The target class
        #
        def target_klass
          target_klass_name.constantize
        end

        # Gives the name which can be used in a liquid template in order
        # to reference an entry. It uses the slug property if the target klass
        # is a Locomotive content type or the class name itself for the other classes.
        #
        # @example
        #
        #   page.target_klass_name = 'Locomotive::Entry12345' # related to the content type Articles
        #   page.target_entry_name = 'article'
        #
        #   page.target_klass_name = 'OurProduct'
        #   page.target_entry_name = 'our_product'
        #
        # @return [ String ] The name in lowercase and underscored
        #
        def target_entry_name
          if self.target_klass_name =~ /^Locomotive::Entry([a-z0-9]+)$/
            @content_type ||= self.site.content_types.find($1)
            @content_type.slug.singularize
          else
            self.target_klass_name.underscore
          end
        end

        # Finds the entry both specified by the target klass and identified by the permalink
        #
        # @param [ String ] permalink The permalink of the entry
        #
        # @return [ Object ] The document
        #
        def fetch_target_entry(permalink)
          target_klass.find_by_permalink(permalink)
        end

        protected

        def set_slug_if_templatized
          self.slug = 'content_type_template' if self.templatized?
        end

        def ensure_target_klass_name_security
          return if !self.templatized? || self.target_klass_name.blank?

          if self.target_klass_name =~ /^Locomotive::Entry([a-z0-9]+)$/
            content_type = Locomotive::ContentType.find($1)

            if content_type.site_id != self.site_id
              self.errors.add :target_klass_name, :security
            end
          elsif !Locomotive.config.models_for_templatization.include?(self.target_klass_name)
            self.errors.add :target_klass_name, :security
          end

        end

      end
    end
  end
end
