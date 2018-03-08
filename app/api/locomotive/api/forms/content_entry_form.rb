module Locomotive
  module API
    module Forms

      class ContentEntryForm < BaseForm

        NON_CUSTOM_FIELD_ATTRIBUTES = %w{_auth_reset_token _auth_reset_sent_at}

        attr_accessor :content_type, :dynamic_attributes

        attrs :_slug, :_position, :_visible, :seo_title, :meta_keywords, :meta_description

        def initialize(content_type, attributes)
          self.content_type = content_type
          self.dynamic_attributes = {}
          super(attributes)
        end

        def set_date_time(field, value)
          dynamic_attributes[:"formatted_#{field.name}"] = value
        end

        alias :set_date :set_date_time

        def set_belongs_to(field, value)
          dynamic_attributes[field.name.to_sym] = fetch_entry_id(field.class_name, value)
        end

        def set_many_to_many(field, value)
          if value.blank?
            dynamic_attributes[:"#{field.name.singularize}_ids"] = [] # reset it
          else
            dynamic_attributes[:"#{field.name.singularize}_ids"] = fetch_entry_ids(field.class_name, value).sort do |a, b|
              # keep the original order
              (value.index(a.first.to_s) || value.index(a.last)) <=>
              (value.index(b.first.to_s) || value.index(b.last))
            end.map(&:first)
          end
        end

        def method_missing(name, *args, &block)
          if field = find_field(name)
            if respond_to?(:"set_#{field.type}")
              public_send(:"set_#{field.type}", field, args.first)
            else
              dynamic_attributes[getter_name(name).to_sym] = args.first
            end
          elsif NON_CUSTOM_FIELD_ATTRIBUTES.include?(getter_name(name))
            dynamic_attributes[getter_name(name).to_sym] = args.first
          else
            super
          end
        end

        def respond_to?(name, include_all = false)
          find_field(name) || NON_CUSTOM_FIELD_ATTRIBUTES.include?(getter_name(name)) || super
        end

        def serializable_hash
          super.merge(self.dynamic_attributes)
        end

        private

        def getter_name(name)
          name.to_s.gsub(/=\z/, '')
        end

        def find_field(name)
          dynamic_setters[getter_name(name)]
        end

        def dynamic_setters
          @dynamic_setters ||= self.content_type.entries_custom_fields.inject({}) do |hash, field|
            case field.type.to_sym
            when :password
              hash[field.name] = hash["#{field.name}_confirmation"] = field
            when :file
              hash[field.name] = hash["remote_#{field.name}_url"] = hash["remove_#{field.name}"] = field
            when :belongs_to
              hash[field.name] = hash["position_in_#{field.name}"] = field
            else
              hash[field.name] = field
            end
            hash
          end.with_indifferent_access
        end

        def fetch_entry_id(class_name, id_or_slug)
          if entry = fetch_entry_ids(class_name, id_or_slug).first
            entry.first
          end
        end

        def fetch_entry_ids(class_name, ids_or_slugs)
          return if ids_or_slugs.blank?

          ids_or_slugs  = [*ids_or_slugs]
          klass         = class_name.constantize

          klass.by_ids_or_slugs(ids_or_slugs).pluck(:_id, :_slug)
        end

      end

    end
  end
end
