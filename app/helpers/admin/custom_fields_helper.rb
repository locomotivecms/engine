module Admin::CustomFieldsHelper
    
  def options_for_field_kind(selected = nil)
    # %w{String Text Boolean Email File Date}
    options = %w{String Text Select}.map do |kind|
      [t("admin.custom_fields.kind.#{kind.downcase}"), kind]
    end    
  end
  
  def options_for_order_by(content_type, collection_name)
    options = %w{updated_at _position_in_list}.map do |type|
      [t("admin.content_types.form.order_by.#{type.gsub(/^_/, '')}"), type]
    end
    options + options_for_highlighted_field(content_type, collection_name)
  end
  
  def options_for_highlighted_field(content_type, collection_name)
    custom_fields_collection_name = "ordered_#{collection_name.singularize}_custom_fields".to_sym
    collection = content_type.send(custom_fields_collection_name)
    collection.delete_if { |f| f.label == 'field name' }
    collection.map { |field| [field.label, field._name] }
  end
  
end