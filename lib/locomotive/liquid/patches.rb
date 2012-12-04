module Liquid
  module StandardFilters

    private

      # Fixme: Handle DateTime, Date and Time objects, convert them
      # into seconds (integer)
      def to_number(obj)
        case obj
        when Numeric
          obj
        when String
          (obj.strip =~ /^\d+\.\d+$/) ? obj.to_f : obj.to_i
        when DateTime, Date, Time
          obj.to_time.to_i
        else
          0
        end
      end
  end
end