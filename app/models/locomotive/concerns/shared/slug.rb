module Locomotive
  module Concerns
    module Shared
      module Slug
        extend ActiveSupport::Concern

        module ClassMethods

          def slugify_from(field)
            class_eval <<-EOV
              before_validation { |object| object.send(:normalize_slug, :#{field.to_s}) }
            EOV
          end

        end

        protected

        def normalize_slug(field)
          value = self.send(field)

          if self.slug.blank? && value.present?
            self.slug = value.clone
          end

          return unless self.slug.present?

          site&.allow_dots_in_slugs ? self.slug.pathify! : self.slug.permalink!
        end

      end
    end
  end
end
