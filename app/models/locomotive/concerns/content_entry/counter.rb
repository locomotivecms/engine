module Locomotive
  module Concerns
    module ContentEntry
      module Counter

        extend ActiveSupport::Concern

        included do

          ## callbacks ##
          after_create  :inc_number_of_entries
          after_destroy :dec_number_of_entries

        end

        def inc_number_of_entries
          self.content_type.inc(number_of_entries: 1)
        end

        def dec_number_of_entries
          self.content_type.inc(number_of_entries: -1)
        end

      end
    end
  end
end
