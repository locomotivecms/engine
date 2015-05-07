module Locomotive
  module API
    module Forms

      class EditableElementForm < BaseForm

        attrs :_id, :_type, :block, :slug, :priority, :hint, :content

        def content=(value)
          if value.respond_to?(:original_filename)
            self._type = 'Locomotive::EditableFile'
          end

          set_attribute :content, value
        end

      end

    end
  end
end
