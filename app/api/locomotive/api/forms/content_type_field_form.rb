module Locomotive
  module API
    module Forms

      class ContentTypeFieldForm < BaseForm

        attr_accessor :content_type_service, :content_type

        attrs :_id, :name, :type, :label, :hint,
              :required, :localized, :unique, :position,
              :text_formatting, :select_options_attributes,
              :target, :inverse_of, :order_by, :ui_enabled,
              :class_name

        def initialize(content_type_service, content_type, attributes)
          self.content_type_service = content_type_service
          self.content_type = content_type
          super(attributes)
        end

        def target=(slug)
          if content_type = self.content_type_service.find_by_slug(slug).first
            self.class_name = content_type.entries_class_name
          end
        end

        def select_options=(options)
          self.select_options_attributes = options.map do |attributes|
            if (name = attributes['name']).is_a?(Hash)
              # deal with translations
              translations = attributes['name_translations'] = attributes.delete('name')
              name = translations[content_type_service.site.default_locale]
            end

            attach_id_to_option(name, attributes)

            attributes
          end
        end

        private

        def attach_id_to_option(name, attributes)
          field = content_type.try(:find_entries_custom_field, self.name)

          return if field.nil?

          if option = field.select_options.where(name: name).first
            # update the option instead of creating it
            attributes[:_id] = option._id
          end
        end

      end

    end
  end
end
