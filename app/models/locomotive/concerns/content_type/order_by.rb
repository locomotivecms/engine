module Locomotive
  module Concerns
    module ContentType
      module OrderBy

        def order_manually?
          self.order_by == '_position'
        end

        def order_by_definition(reverse_order = false)
          direction = self.order_manually? ? 'asc' : self.order_direction || 'asc'

          if reverse_order
            direction = (direction == 'asc' ? 'desc' : 'asc')
          end

          [order_by_attribute, direction]
        end

        def order_by_attribute
          case self.order_by
          when '_position'
            self.sortable_column
          when 'created_at', 'updated_at'
            self.order_by
          else
            self.entries_custom_fields.find(self.order_by).name rescue 'created_at'
          end
        end

        def sortable_column
          # only the belongs_to field has a special column for relative positionning
          # that's why we don't call groupable?
          if self.group_by_field.try(:type) == 'belongs_to' && self.order_manually?
            "position_in_#{self.group_by_field.name}"
          else
            '_position'
          end
        end

      end
    end
  end
end
