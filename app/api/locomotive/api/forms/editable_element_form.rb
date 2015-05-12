module Locomotive
  module API
    module Forms

      class EditableElementForm < BaseForm

        TYPES = %w(file text control)

        # Fix bug in Rails: http://stackoverflow.com/questions/18472876/instantiate-mongoid-subclasses-by-type-field
        TYPES.each do |type|
          "Locomotive::Editable#{type.classify}".constantize.inspect
        end

        attrs :_id, :_type, :block, :slug, :priority, :hint, :content

        def content=(value)
          if value.respond_to?(:original_filename) || value.respond_to?(:tempfile)
            self._type = :file
          end

          set_attribute :content, value
        end

        def _type=(type)
          return unless TYPES.include?(type.to_s)
          set_attribute :_type, "Locomotive::Editable#{type.to_s.classify}"
        end

      end

    end
  end
end
