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

  module PageScopeMethods

   def to_liquid(options = {})
     {
       :collection       => to_a,
       :current_page     => current_page,
       :previous_page    => first_page? ? nil : current_page - 1,
       :total_entries    => total_count,
       :per_page         => limit_value
     }.tap do |hash|
       # note: very important to avoid extra and useless mongodb requests
       hash[:total_pages] = (hash[:total_entries].to_f / limit_value).ceil
       hash[:next_page]   = current_page >= hash[:total_pages] ? nil : current_page + 1
     end
   end

  end
end
