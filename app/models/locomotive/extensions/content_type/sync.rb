module Locomotive
  module Extensions
    module ContentType
      module Sync

        extend ActiveSupport::Concern

        included do
          after_save :sync_relationships_order_by
        end

        protected

        # If the user changes the order of the content type, we have to make
        # sure that other related content types tied to the current one through
        # a belongs_to / has_many relationship also gets updated.
        #
        def sync_relationships_order_by
          current_class_name = self.klass_with_custom_fields(:entries).name

          self.entries_custom_fields.where(:type => 'belongs_to').each do |field|
            target_content_type = self.class_name_to_content_type(field.class_name)

            operations = { '$set' => {} }

            target_content_type.entries_custom_fields.where(:type.in => %w(has_many many_to_many), :ui_enabled => false, :class_name => current_class_name).each do |target_field|
              if target_field.order_by != self.order_by_definition
                target_field.order_by = self.order_by_definition # needed by the custom_fields_recipe_for method in order to be up to date

                operations['$set']["entries_custom_fields.#{target_field._index}.order_by"] = self.order_by_definition
              end
            end

            unless operations['$set'].empty?
              persist_content_type_changes target_content_type, operations
            end
          end
        end

        # Save the changes for the content type passed in parameter without forgetting
        # to bump the version.. It also updates the recipe for related entries.
        # That method does not call the Mongoid API but directly MongoDB.
        #
        # @param [ ContentType ] content_type The content type to update
        # @param [ Hash ] operations The MongoDB atomic operations
        #
        def persist_content_type_changes(content_type, operations)
          content_type.entries_custom_fields_version += 1

          operations['$set']['entries_custom_fields_version'] = content_type.entries_custom_fields_version

          self.collection.update({ '_id' => content_type._id }, operations)

          collection, selector = content_type.entries.collection, content_type.entries.criteria.selector

          collection.update selector, { '$set' => { 'custom_fields_recipe' => content_type.custom_fields_recipe_for(:entries) } }, :multi => true
        end

      end
    end
  end
end