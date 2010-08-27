module Models
  module Extensions
    module Page
      module EditableElements

        extend ActiveSupport::Concern

        included do
          embeds_many :editable_elements

          accepts_nested_attributes_for :editable_elements
        end

        module InstanceMethods

          def disable_parent_editable_elements(block)
            self.editable_elements.each { |el| el.disabled = true if el.from_parent? && el.block == block }
          end

          def editable_element_blocks
            self.editable_elements.collect(&:block)
          end

          def editable_elements_grouped_by_blocks
            groups = self.editable_elements.group_by(&:block)
            groups.delete_if { |block, elements| elements.all? { |el| el.disabled? } }
          end

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
            # TODO: only if block != blank
            self.editable_elements.each { |el| el.disabled = true }
          end

          def enable_editable_elements(block)
            self.editable_elements.each { |el| el.disabled = false if el.block == block }
          end

          def merge_editable_elements_from_page(source)
            source.editable_elements.each do |el|
              next if el.disabled?

              existing_el = self.find_editable_element(el.block, el.slug)

              if existing_el.nil? # new one from parents
                self.editable_elements.build(el.attributes.merge(:from_parent => true))
              else
                existing_el.disabled = false
              end
            end
          end

        end

      end
    end
  end
end