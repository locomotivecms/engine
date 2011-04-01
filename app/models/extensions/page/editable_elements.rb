module Extensions
  module Page
    module EditableElements

      extend ActiveSupport::Concern

      included do
        embeds_many :editable_elements

        after_save :remove_disabled_editable_elements

        # editable file callbacks
        after_save :store_file_sources!
        before_save :write_file_source_identifiers
        after_destroy :remove_file_sources!

        accepts_nested_attributes_for :editable_elements
      end

      module InstanceMethods

        def disable_parent_editable_elements(block)
          self.editable_elements.each { |el| el.disabled = true if el.from_parent? && el.block == block }
        end

        def disable_all_editable_elements
          self.editable_elements.each { |el| el.disabled = true }
        end

        def editable_element_blocks
          self.editable_elements.collect(&:block)
        end

        def editable_elements_grouped_by_blocks
          all_enabled = self.editable_elements.reject { |el| el.disabled? }
          groups = all_enabled.group_by(&:block)
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
            element.attributes = attributes
          else
            self.editable_elements.build(attributes, type)
          end
        end

        def enable_editable_elements(block)
          self.editable_elements.each { |el| el.disabled = false if el.block == block }
        end

        def merge_editable_elements_from_page(source)
          source.editable_elements.each do |el|
            next if el.disabled? or !el.assignable?

            existing_el = self.find_editable_element(el.block, el.slug)

            if existing_el.nil? # new one from parents
              new_attributes = el.attributes.merge(:from_parent => true)
              if new_attributes['default_attribute'].present?
                new_attributes['default_content'] = self.send(new_attributes['default_attribute']) || el.content
              else
                new_attributes['default_content'] = el.content
              end

              self.editable_elements.build(new_attributes, el.class)
            elsif existing_el.default_attribute.nil?
              existing_el.attributes = { :disabled => false, :default_content => el.content }
            else
              existing_el.attributes = { :disabled => false }
            end
          end
        end

        def remove_disabled_editable_elements
          return unless self.editable_elements.any? { |el| el.disabled? }

          # super fast way to remove useless elements all in once (TODO callbacks)
          self.collection.update(self._selector, '$pull' => { 'editable_elements' => { 'disabled' => true } })
        end

        protected

        ## callbacks for editable files

        # equivalent to "after_save :store_source!" in EditableFile
        def store_file_sources!
          self.find_editable_files.collect(&:store_source!)
        end

        # equivalent to "before_save :write_source_identifier" in EditableFile
        def write_file_source_identifiers
          self.find_editable_files.collect(&:write_source_identifier)
        end

        # equivalent to "after_destroy :remove_source!" in EditableFile
        def remove_file_sources!
          self.find_editable_files.collect(&:remove_source!)
        end

      end

    end
  end
end