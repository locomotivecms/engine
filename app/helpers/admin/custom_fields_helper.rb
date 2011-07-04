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

  def options_for_has_one(field, value)
    self.options_for_has_one_or_has_many(field) do |groups|
      grouped_options_for_select(groups.collect do |g|
        if g[:items].empty?
          nil
        else
          [g[:name], g[:items].collect { |c| [c._label, c._id] }]
        end
      end.compact, value)
    end
  end

  def options_for_has_many(field)
    self.options_for_has_one_or_has_many(field)
  end

  def options_for_has_one_or_has_many(field, &block)
    content_type = field.target.constantize._parent

    if content_type.groupable?
      grouped_contents = content_type.list_or_group_contents

      if block_given?
        block.call(grouped_contents)
      else
        grouped_contents.collect do |g|
          if g[:items].empty?
            nil
          else
            { :name => g[:name], :items => g[:items].collect { |c| [c._label, c._id] } }
          end
        end.compact
      end
    else
      contents = content_type.ordered_contents
      contents.collect { |c| [c._label, c._id] }
    end
  end

end
