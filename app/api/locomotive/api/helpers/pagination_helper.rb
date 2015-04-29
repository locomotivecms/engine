module Locomotive
  module API
    module Helpers
      module PaginationHelper

        def add_pagination_header(collection)
          header 'X-Total-Pages',   collection.num_pages.to_s
          header 'X-Per-Page',      collection.limit_value.to_s
          header 'X-Total-Entries', collection.total_count.to_s
        end

      end

    end
  end
end
