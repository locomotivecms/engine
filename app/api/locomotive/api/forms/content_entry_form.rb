module Locomotive
  module API
    module Forms

      class ContentEntryForm < BaseForm

        attr_accessor :content_type

        attrs :_slug, :_position, :_visible, :seo_title, :meta_keywords, :meta_description

        def initialize(content_type, attributes)
          self.content_type = content_type
          super(attributes)
        end

        def set_string_attribute(name, value)
          set_attribute(name, value)
        end

        alias :set_text_attribute :set_string_attribute
        alias :set_boolean_attribute :set_string_attribute

        def set_date_time_attribute(name, value)
          set_attribute(:"formatted_#{name}", value)
        end

        def get_string_attribute(name)
          get_attribute(name)
        end

        alias :get_text_attribute :get_string_attribute
        alias :get_boolean_attribute :get_string_attribute

        def get_date_time_attribute(name)
          get_attribute(:"formatted_#{name}")
        end

        def method_missing(symbol, *args, &block)
          if field = find_field(symbol)
            if symbol.to_s =~ /=$/
              send(:"set_#{field.type}_attribute", field.name, args.first)
            else
              send(:"get_#{field.type}_attribute", field.name)
            end
          else
            super
          end
        end

        def respond_to?(symbol, include_all = false)
          if super
            true
          else
            find_field(symbol).present?
          end
        end

        private

        def find_field(name)
          _name = name.to_s.gsub(/=$/, '').gsub(/^formatted_/, '')
          self.content_type.entries_custom_fields.where(name: _name).first
        end

        def set_attribute(name, value)
          attribute_will_change!(name)
          instance_variable_set(:"@#{name}", value)
        end

        def get_attribute(name)
          instance_variable_get(:"@#{name}")
        end

      end

    end
  end
end
