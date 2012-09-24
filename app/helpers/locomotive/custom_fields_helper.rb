module Locomotive
  module CustomFieldsHelper

    def options_for_custom_field_type
      %w(string text select boolean date file belongs_to has_many many_to_many).map do |type|
        [t("custom_fields.type.#{type}"), type]
      end
    end

    def options_for_label_field(content_type)
      content_type.ordered_entries_custom_fields.find_all do |field|
        %w(string date).include?(field.type)
      end.map do |field|
        [field.label, field._id]
      end
    end

    def options_for_group_by_field(content_type)
      content_type.ordered_entries_custom_fields.find_all do |field|
        %w(select belongs_to).include?(field.type)
      end.map do |field|
        [field.label, field._id]
      end
    end

    def options_for_order_by(content_type)
      options = %w{created_at updated_at _position}.map do |type|
        [t("locomotive.content_types.form.order_by.#{type.gsub(/^_/, '')}"), type]
      end
      options + options_for_label_field(content_type)
    end

    def options_for_order_direction
      %w(asc desc).map do |direction|
        [t("locomotive.content_types.form.order_direction.#{direction}"), direction]
      end
    end

    def options_for_text_formatting
      %w(none html).map do |option|
        [t("locomotive.custom_fields.text_formatting.#{option}"), option]
      end
    end

    def options_for_content_type
      current_site.content_types.map do |c|
        [c.name, c.klass_with_custom_fields(:entries).to_s]
      end.compact
    end

    def options_for_content_type_inverse_of
      {}.tap do |hash|
        current_site.content_types.where(:'entries_custom_fields.type'.in => %w(belongs_to many_to_many)).each do |content_type|
          content_type.entries_custom_fields.each do |field|
            if %w(belongs_to many_to_many).include?(field.type)
              type = field.type == 'belongs_to' ? 'has_many' : field.type
              hash[type] ||= []
              hash[type] << {
                :label      => field.label,
                :name       => field.name,
                :class_name => content_type.klass_with_custom_fields(:entries).to_s
              }
            end
          end
        end
      end
    end

  end
end