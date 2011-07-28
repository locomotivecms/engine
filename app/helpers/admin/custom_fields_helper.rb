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

  def options_for_reverse_lookups(my_content_type)
    opts = []
    ContentType.all.each do |ct|
      ct.content_custom_fields.each do |cf|
        if cf.kind == 'has_one' && cf.target == my_content_type.content_klass.to_s
          opts << {
            :content_type => ct.content_klass.to_s,
            :field_name => cf.label,
            :field => cf._alias,
          }
        end
      end
    end

    return opts
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

  def options_for_has_many(field, object=nil)
    self.options_for_has_one_or_has_many(field, object)
  end

  def filter_options_for_reverse_has_many(contents, reverse_lookup, object)
    # Only display items which don't belong to a different object
    contents.reject do |c|
      owner = c.send(reverse_lookup.to_sym)
      owner && owner != object
    end
  end

  def options_for_has_one_or_has_many(field, object=nil, &block)
    content_type = field.target.constantize._parent

    if content_type.groupable?
      grouped_contents = content_type.list_or_group_contents

      if field.reverse_has_many?
        grouped_contents.each do |g|
          g[:items] = filter_options_for_reverse_has_many(g[:items], field.reverse_lookup, object)
        end
      end

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

      if field.reverse_has_many?
        contents = filter_options_for_reverse_has_many(contents, field.reverse_lookup, object)
      end

      contents.collect { |c| [c._label, c._id] }
    end
  end

end
