module Locomotive
  module Concerns
    module Page
      module EditableElements

        extend ActiveSupport::Concern

        included do
          embeds_many   :editable_elements, class_name: 'Locomotive::EditableElement', cascade_callbacks: true

          accepts_nested_attributes_for :editable_elements
        end

        def find_editable_element(block, slug)
          self.editable_elements.detect { |el| el.block == block && el.slug == slug }
        end

      end
    end
  end
end
