module Locomotive
  module Concerns
    module ContentEntry
      module NextPrevious

        # Return the next content entry based on the order defined in the parent content type.
        #
        # @param [ Object ] The next content entry or nil if not found
        #
        def next
          next_or_previous :gt
        end

        # Return the previous content entry based on the order defined in the parent content type.
        #
        # @param [ Object ] The previous content entry or nil if not found
        #
        def previous
          next_or_previous :lt
        end

        protected

        # Retrieve the next or the previous entry following the order
        # defined in the parent content type.
        #
        # @param [ Symbol ] :gt for the next element, :lt for the previous element
        #
        # @return [ Object ] The next or previous content entry or nil if none
        #
        def next_or_previous(matcher = :gt)
          # the matchers is supposed to be fine for the default direction, meaning 'asc'
          # if the direction is not ascending, we need to reverse the matcher
          matcher = matcher == :gt ? :lt : :gt if self.content_type.order_direction != 'asc'

          attribute = self.content_type.order_by_attribute
          direction = matcher == :gt ? 'asc' : 'desc'

          criterion = attribute.to_sym.send(matcher)
          value     = self.send(attribute.to_sym)
          order_by  = [attribute, direction]

          self.class.next_or_previous({ criterion => value }, order_by).first
        end

      end
    end
  end
end
