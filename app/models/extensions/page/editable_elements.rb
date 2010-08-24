module Models
  module Extensions
    module Page
      module EditableElements

        extend ActiveSupport::Concern

        included do
          embeds_many :editable_elements
        end

        module InstanceMethods

          def find_editable_element(block, slug)
            self.editable_elements.detect { |el| el.block == block && el.slug == slug }
          end

          def add_or_update_editable_element(attributes)
            element = self.find_editable_element(attributes[:block], attributes[:slug])

            if element
              element.attributes = attributes
            else
              self.editable_elements.build(attributes)
            end
          end

          def disable_all_editable_elements
            self.editable_elements.each { |el| el.disabled = true }
          end

          def enable_editable_elements(block)
            self.editable_elements.each { |el| el.disabled = false if el.block == block }
          end

          def merge_editable_elements_from_page(source)
            source.editable_elements.each do |el|
              existing_el = self.find_editable_element(el.block, el.slug)

              if existing_el.nil? # new one from parents
                self.editable_elements.build(el.attributes.merge(:disabled => true))
              end
            end
          end

        end

      end
    end
  end
end