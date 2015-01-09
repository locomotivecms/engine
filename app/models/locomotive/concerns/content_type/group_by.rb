module Locomotive
  module Concerns
    module ContentType
      module GroupBy

        # List the name and _id of the groups if the entries
        # are grouped by a field. The type of this field can be either
        # a select or a belongs_to.
        # It returns nil if groupable? returns false.
        #
        # @return [ Array ] List of hashes (:name and :_id as keys).
        #
        def list_of_groups
          return nil unless self.groupable?

          field = self.group_by_field

          case field.type.to_sym
          when :select
            self.entries_class._select_options(field.name).map(&:with_indifferent_access)
          when :belongs_to
            target  = self.class_name_to_content_type(field.class_name)
            label   = target.label_field_name.to_sym

            target.ordered_entries.only(:_id, label).map do |entry|
              { _id: entry._id, name: entry.send(label) }
            end
          end
        end

        def groupable?
          !!self.group_by_field && %w(select belongs_to).include?(group_by_field.type)
        end

        def group_by_field
          self.find_entries_custom_field(self.group_by_field_id)
        end

      end
    end
  end
end
