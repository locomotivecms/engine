module Locomotive
  module Concerns
    module ContentType
      module Sync

        extend ActiveSupport::Concern

        included do
          before_update :sync_relationships_order_by_for_has_many_fields
          after_save    :sync_relationships_order_by_for_belongs_to_fields
        end

        protected

        # If an user changes the default order of a content type, we need to make sure
        # that all the content types referencing this content type through a has_many
        # relationship without UI enabled (this is very important) have the new order_by.
        #
        def sync_relationships_order_by_for_belongs_to_fields
          current_class_name = self.klass_with_custom_fields(:entries).name

          self.entries_custom_fields.where(type: 'belongs_to').each do |field|
            target_content_type = self.class_name_to_content_type(field.class_name)

            operations = { '$set' => {} }

            target_content_type.entries_custom_fields.where(:type.in => %w(has_many many_to_many), ui_enabled: false, class_name: current_class_name).each do |target_field|
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

        # If an user enables the UI option for a has_many relationship in the current content type,
        # then all the content entries of that content type should order the entries of the has_many relationship
        # from the "position_in_<field name>" value.
        #
        def sync_relationships_order_by_for_has_many_fields
          self.entries_custom_fields.where(:type.in => %w(has_many), ui_enabled: true).each do |field|
            field.order_by = nil # that will force the content entry to use the position_in_<inverse_of> field
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

          self.collection.find(_id: content_type._id).update_one(operations)

          collection, selector = content_type.entries.collection, content_type.entries.criteria.selector

          collection.find(selector).update_many('$set' => { 'custom_fields_recipe' => content_type.custom_fields_recipe_for(:entries) })
        end

      end
    end
  end
end
