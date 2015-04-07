module Locomotive
  class ContentTypeForm < BaseForm

    attr_accessor :_id

    attrs :name, :slug, :description, :label_field_name,
          :order_by, :order_direction, :group_by_field_id,
          :group_by_field_name, :public_submission_enabled,
          :public_submission_account_emails, :raw_item_template,
          :entries_custom_fields_attributes

    # If the current content type exists, look up the fields and add their IDs
    #  to the attributes hash.  If not, set the entries_custom_fields_attributes
    #  as-is
    def entries_custom_fields_attributes=(fields)
      entries_custom_fields_attributes_will_change!
      @entries_custom_fields_attributes =
        if existing_content_type.present?
          fields.map do |attrs|
            if field = existing_content_type.find_entries_custom_field(attrs[:name])
              attrs[:_id] = field._id
              if attrs[:_destroy] # slim down hash if destroying.
                attrs = { _id: attrs[:_id], _destroy: true }
              end
            end
            attrs
          end
        else
          fields
        end
    end

    def entries_custom_fields
      list = self.__source.ordered_entries_custom_fields
      list ? list.map(&:as_json) : []
    end

    private

    def existing_content_type
      @existing_content_type ||= content_type_service.find_by_slug(slug)
    end

    delegate :find_by_slug, to: :content_type_service

    def content_type_service
      @content_type_service ||= ContentTypeService.new(_site)
    end

    def custom_field_finder_service
      @custom_field_finder_service ||= begin
        CustomFieldFinderService.new(existing_content_type)
      end
    end

    # # lookup content type by slug
    # content_type = ContentTypeService.find_by_slug(attr[:slug])
    # fields.each
    #   # lookup field by name
    #   if field = CustomFieldService.find_by_name(content_type, attr[:name])
    #     # existing field
    #     attr[:_id] = field._id
    #   end
    #

    # override
    # def entries_custom_fields=(fields)
    #   entries_custom_fields_will_change! unless entries_custom_fields == fields
    #   destroyed_fields = []
    #
    #   fields.each do |attributes|
    #     id_or_name  = attributes.delete('id') || attributes.delete('_id') || attributes['name']
    #     field       = self.__source.find_entries_custom_field(id_or_name)
    #
    #     if field && !!attributes.delete('_destroy')
    #       destroyed_fields << { _id: field._id, _destroy: true }
    #       next
    #     end
    #
    #     field ||= self.__source.entries_custom_fields.build
    #
    #     field.from_presenter(attributes)
    #   end
    #
    #   # shift to the accepts_nested_attributes function to delete fields
    #   self.__source.entries_custom_fields_attributes = destroyed_fields
    # end
  end
end
