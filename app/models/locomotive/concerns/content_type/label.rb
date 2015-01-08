module Locomotive
  module Concerns
    module ContentType
      module Label

        def label_field_id=(value)
          # update the label_field_name if the label_field_id is changed
          new_label_field_name = self.entries_custom_fields.where(_id: value).first.try(:name)
          self.label_field_name = new_label_field_name
          super(value)
        end

        def label_field_name=(value)
          # mandatory if we allow the API to set the label field name without an id of the field
          @new_label_field_name = value unless value.blank?
          super(value)
        end

      end
    end
  end
end
