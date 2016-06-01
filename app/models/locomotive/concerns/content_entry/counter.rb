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

        private

        def inc_number_of_entries
          change_number_of_entries(1)
        end

        def dec_number_of_entries
          change_number_of_entries(-1)
        end

        def change_number_of_entries(delta)
          Locomotive::ContentType.collection.update_one(
            { _id: self.content_type_id },
            {
              '$inc' => { 'number_of_entries' => delta },
              '$set' => { 'updated_at' => Time.zone.now }
            })
        end

      end
    end
  end
end
