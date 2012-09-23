module Locomotive
  module Extensions
    module Page
      module EditableElements

        extend ActiveSupport::Concern

        included do
          embeds_many   :editable_elements, :class_name => 'Locomotive::EditableElement', :cascade_callbacks => true

          after_save    :remove_disabled_editable_elements

          accepts_nested_attributes_for :editable_elements
        end

        def disable_parent_editable_elements(block)
          self.editable_elements.each { |el| el.disabled = true if el.from_parent? && el.block == block }
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
          self.editable_elements.each { |el| el.disabled = false if el.block == block }
        end

        def merge_editable_elements_from_page(source)
          source.editable_elements.each do |el|
            next if el.disabled?

            existing_el = self.find_editable_element(el.block, el.slug)

            Rails.logger.debug "[merge_editable_elements_from_page] el = #{el.block.inspect} / #{el.slug.inspect} / not found ? #{existing_el.nil?.inspect} / #{::Mongoid::Fields::I18n.locale.inspect}"

            if existing_el.nil? # new one from parents
              new_el = self.editable_elements.build({}, el.class)
              new_el.copy_attributes_from(el)
            else
              Rails.logger.debug "___ #{existing_el.changes.inspect} ____ [BEFORE]"

              existing_el.disabled = false

              Rails.logger.debug "___ #{existing_el.changes.inspect} ____ [AFTER]"

              # make sure the default content gets updated too
              existing_el.set_default_content_from(el)

              # Rails.logger.debug "====> #{existing_el.inspect}"

              Rails.logger.debug "___ #{existing_el.changes.inspect} ____"

              # only the type, hint and fixed properties can be modified from the parent element
              %w(_type hint fixed).each do |attr|
                existing_el.send(:"#{attr}=", el.send(attr.to_sym))
              end
            end
          end
        end

        def remove_disabled_editable_elements
          # get only those which are fully disabled, meaning in ALL the locales
          ids = self.editable_elements.find_all { |el| el.disabled_in_all_translations? }.map(&:_id)

          return if ids.empty?

          # super fast way to remove useless elements all in once
          self.collection.update(self.atomic_selector, '$pull' => { 'editable_elements' => { '_id' => { '$in' => ids } } })
        end

      end
    end
  end
end