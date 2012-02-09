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
        end

        def target_klass
          target_klass_name.constantize
        end

        def target_entry_name
          if self.target_klass_name =~ /^Locomotive::Entry([a-z0-9]+)$/
            @content_type ||= self.site.content_types.find($1)
            @content_type.slug.singularize
          else
            self.target_klass_name.underscore
          end
        end

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
