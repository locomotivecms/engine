module Locomotive
  module API
    module Entities

      class EditableElementEntity < BaseEntity

        expose :slug, :block, :hint, :priority, :fixed, :content

        expose :type do |editable_element, _|
          editable_element._type.to_s.demodulize
        end

      end

    end
  end
end
