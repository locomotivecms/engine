module Locomotive
  module Extensions
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

          if self.slug.present?
            self.slug.permalink!
          end
        end

      end
    end
  end
end