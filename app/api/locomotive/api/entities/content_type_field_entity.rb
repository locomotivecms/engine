module Locomotive
  module API
    module Entities

      class ContentTypeFieldEntity < BaseEntity

        expose :name, :type, :label, :hint, :required, :localized, :unique, :default, :position, :group

        # text type field
        expose :text_formatting, if: ->(field, _) { field.type.to_s == 'text' }

        # select type field
        expose :select_options, if: ->(field, _) { field.type.to_s == 'select' } do |field, _|
          field.select_options.map do |option|
            { id: option._id, name: option.name_translations, position: option.position }
          end
        end

        # relationship type field
        with_options if: ->(field, _) { field.is_relationship? } do

          expose :target do |field, _|
            field.class_name_to_content_type.try(:slug) rescue nil
          end

          expose :inverse_of, :order_by, :ui_enabled

        end

      end

    end
  end
end
