module Locomotive
  module Liquid
    module Drops
      class Site < Base

        liquid_attributes << :name << :meta_keywords << :meta_description

        def index
          @index ||= @source.pages.root.first
        end

      end
    end
  end
end
