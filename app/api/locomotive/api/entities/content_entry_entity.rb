module Locomotive
  module API
    module Entities

      class ContentEntryEntity < BaseEntity

        expose :_slug

        expose :content_type_slug do |content_entry, _|
          content_entry.content_type.slug
        end

        expose :_label, :_position, :_visible

        expose :seo_title, :meta_keywords, :meta_description

        expose :dynamic_fields

        def serializable_hash(runtime_options = {})
          (super || {}).dup.tap do |hash|
            hash.merge!(hash.delete(:dynamic_fields) || hash.delete('dynamic_fields') || {})
          end
        end

        def dynamic_fields
          content_type.entries_custom_fields.inject({}) do |hash, field|
            name        = field.name.to_sym
            method_name = :"expose_#{field.type}_field"

            hash[name] = send(method_name, name) if respond_to?(method_name)

            hash
          end
        end

        def expose_default_field(name)
          dynamic_value_of(name)
        end

        alias :expose_string_field    :expose_default_field
        alias :expose_text_field      :expose_default_field
        alias :expose_boolean_field   :expose_default_field
        alias :expose_email_field     :expose_default_field
        alias :expose_integer_field   :expose_default_field
        alias :expose_float_field     :expose_default_field
        alias :expose_tags_field      :expose_default_field

        def expose_money_field(name)
          dynamic_value_of(:"formatted_#{name}")
        end

        def expose_date_time_field(name)
          instance_exec(dynamic_value_of(name), &formatters[:iso_timestamp])
        end

        alias :expose_date_field :expose_date_time_field

        def expose_file_field(name)
          dynamic_value_of(:"#{name}_url")
        end

        def expose_select_field(name)
          dynamic_value_of(name)
        end

        def expose_belongs_to_field(name)
          dynamic_value_of(name).try(:_slug)
        end

        def expose_many_to_many_field(name)
          dynamic_value_of(name).pluck_with_natural_order(:_slug)
        end

        def expose_json_field(name)
          expose_default_field(name).try(:to_json)
        end

        def dynamic_value_of(name)
          self.object.send(name)
        end

        def content_type
          self.object.content_type
        end

      end

    end
  end
end
