module Locomotive
  module Liquid
    module Drops
      class Site < Base

        liquid_attributes << :name << :seo_title << :meta_keywords << :meta_description

        def index
          @index ||= self._source.pages.root.first
        end

        def pages
          @pages ||= self._source.pages.to_a.collect(&:to_liquid)
        end

      end
    end
  end
end
