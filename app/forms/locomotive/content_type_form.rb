module Locomotive
  class ContentTypeForm < BaseForm

    attrs :name, :slug, :description, :label_field_name,
          :order_by, :order_direction, :group_by_field_id,
          :group_by_field_name, :public_submission_enabled,
          :public_submission_account_emails, :raw_item_template

    def entries_custom_fields=(fields)
      entries_custom_fields_will_change! unless entries_custom_fields == fields
      destroyed_fields = []

      fields.each do |attributes|
        id_or_name  = attributes.delete('id') || attributes.delete('_id') || attributes['name']
        field       = self.__source.find_entries_custom_field(id_or_name)

        if field && !!attributes.delete('_destroy')
          destroyed_fields << { _id: field._id, _destroy: true }
          next
        end

        field ||= self.__source.entries_custom_fields.build

        field.from_presenter(attributes)
      end

      # shift to the accepts_nested_attributes function to delete fields
      self.__source.entries_custom_fields_attributes = destroyed_fields
    end
  end
end
