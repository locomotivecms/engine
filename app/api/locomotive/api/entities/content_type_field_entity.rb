module Locomotive
  module API
    module Entities

      class ContentTypeFieldEntity < BaseEntity

        expose :name, :type, :label, :hint, :required, :localized, :unique, :position

        # TEXT
        expose :text_formatting, if: ->(field, _) { field.type.to_s == 'text' }

        # SELECT
        expose :select_options, if: ->(field, _) { field.type.to_s == 'select'} do |field, _|
          field.select_options.map do |option|
            { id: option._id, name: option.name_translations, position: option.position }
          end
        end

      end

    end
  end
end
