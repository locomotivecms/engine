module Locomotive
  module Extensions
    module Page
      module EditableElements

        extend ActiveSupport::Concern

        included do
          embeds_many   :editable_elements, class_name: 'Locomotive::EditableElement', cascade_callbacks: true

          after_save    :remove_disabled_editable_elements

          accepts_nested_attributes_for :editable_elements
        end

        def disable_parent_editable_elements(block)
          Rails.logger.debug "[disable_parent_editable_elements] #{block.inspect}"
          self.editable_elements.each do |el|
            if el.from_parent? && (el.block == block || el.block =~ %r(^#{block}/))
              el.disabled = true
            end
          end
        end

        def disable_all_editable_elements
          self.editable_elements.each { |el| el.disabled = true }
        end

        def editable_element_blocks
          self.editable_elements.collect(&:block)
        end

        def enabled_editable_elements
          self.editable_elements.by_priority.find_all(&:editable?)
        end

        def editable_elements_grouped_by_blocks
          groups = self.enabled_editable_elements.group_by(&:block)
          groups.delete_if { |block, elements| elements.empty? }
        end

        def find_editable_elements(block)
          self.editable_elements.find_all { |el| el.block == block }
        end

        def find_editable_element(block, slug)
          self.editable_elements.detect { |el| el.block == block && el.slug == slug }
        end

        def find_editable_files
          self.editable_elements.find_all { |el| el.respond_to?(:source) }
        end

        def add_or_update_editable_element(attributes, type)
          element = self.find_editable_element(attributes[:block], attributes[:slug])

          if element
            element.copy_attributes(attributes)
          else
            element = self.editable_elements.build(attributes, type)
          end

          element.add_current_locale

          element
        end

        def enable_editable_elements(block)
          Rails.logger.debug "[enable_editable_elements] #{block.inspect}"
          self.editable_elements.each { |el| el.disabled = false if el.block == block }
        end

        def merge_editable_elements_from_page(source)
          source.editable_elements.each do |el|
            next if el.disabled?

            existing_el = self.find_editable_element(el.block, el.slug)

            if existing_el.nil? # new one from parents
              new_el = self.editable_elements.build({}, el.class)
              new_el.copy_attributes_from(el)
            elsif existing_el.from_parent? # it inherits from a parent page
              existing_el.disabled = false

              # same type ? if not, convert it
              if existing_el._type != el._type
                existing_el = self.change_element_type(existing_el, el.class)
              end

              # make sure the default content gets updated too
              existing_el.set_default_content_from(el)

              # copy _type, hint, fixed, priority and locales + type custom attributes
              existing_el.copy_default_attributes_from(el)
            end
          end
        end

        def change_element_type(element, klass)
          # build the new element
          self.editable_elements.build({}, klass).tap do |new_element|
            # copy the most important mongoid internal attributes
            %w{_id _index new_record}.each do |attr|
              new_element.send(:"#{attr}=", element.send(attr.to_sym))
            end

            # copy the main attributes from the previous version
            new_element.attributes = element.attributes.reject { |attr| !%w(slug block from_parent).include?(attr) }

            # remove the old one
            self.editable_elements.delete_one(element)
          end
        end

        def remove_disabled_editable_elements
          # get only those which are fully disabled, meaning in ALL the locales
          ids = self.editable_elements.find_all { |el| el.disabled_in_all_translations? }.map(&:_id)

          return if ids.empty?

          # super fast way to remove useless elements all in once
          self.collection.find(self.atomic_selector).update('$pull' => { 'editable_elements' => { '_id' => { '$in' => ids } } })

          # mark them as destroyed
          self.editable_elements.each do |el|
            next unless ids.include?(el._id)
            el.destroyed = true
          end
        end

      end
    end
  end
end