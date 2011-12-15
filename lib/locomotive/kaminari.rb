require 'kaminari'

module Kaminari
  class PaginatableArray < Array
    def to_liquid(options = {})
      {
        :collection       => to_a,
        :current_page     => current_page,
        :previous_page    => first_page? ? nil : current_page - 1,
        :next_page        => last_page? ? nil : current_page + 1,
        :total_entries    => total_count,
        :total_pages      => num_pages,
        :per_page         => limit_value
      }
    end
  end
end
