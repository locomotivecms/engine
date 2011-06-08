module Admin::CustomFieldsHelper

  def options_for_field_kind
    %w(string text category boolean date file has_one has_many).map do |kind|
      [t("custom_fields.kind.#{kind}"), kind]
    end
  end

  def options_for_order_by(content_type, collection_name)
    options = %w{created_at updated_at _position_in_list}.map do |type|
      [t("admin.content_types.form.order_by.#{type.gsub(/^_/, '')}"), type]
    end
    options + options_for_highlighted_field(content_type, collection_name)
  end

  def options_for_order_direction
    %w(asc desc).map do |direction|
      [t("admin.content_types.form.order_direction.#{direction}"), direction]
    end
  end

  def options_for_highlighted_field(content_type, collection_name)
    custom_fields_collection_name = "ordered_#{collection_name.singularize}_custom_fields".to_sym
    collection = content_type.send(custom_fields_collection_name)
    collection.delete_if { |f| f.label == 'field name' || f.kind == 'file' }
    collection.map { |field| [field.label, field._name] }
  end

  def options_for_group_by_field(content_type, collection_name)
    custom_fields_collection_name = "ordered_#{collection_name.singularize}_custom_fields".to_sym
    collection = content_type.send(custom_fields_collection_name)
    collection.delete_if { |f| not f.category? }
    collection.map { |field| [field.label, field._name] }
  end

  def options_for_text_formatting
    options = %w(none html).map do |option|
      [t("admin.custom_fields.text_formatting.#{option}"), option]
    end
  end

  def options_for_association_target
    current_site.content_types.collect do |c|
      c.persisted? ? [c.name, c.content_klass.to_s] : nil
    end.compact
  end

  def options_for_has_one(field)
    target_contents_from_field(field).collect { |c| [c._label, c._id] }
  end

  alias :options_for_has_many :options_for_has_one

  def target_contents_from_field(field)
    content_type = field.target.constantize._parent
    content_type.ordered_contents
  end

end
