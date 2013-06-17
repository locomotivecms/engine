module Locomotive
  module Liquid
    module Drops
      class Site < Base

        delegate :name, :seo_title, :meta_keywords, :meta_description, to: '_source'

        def index
          @index ||= self._source.pages.root.first
        end

        def pages
          @pages ||= liquify(*self.scoped_pages)
        end

        protected
        def scoped_pages
          if @context["with_scope"]
            self._source.pages.where(@context["with_scope"])
          else
            self._source.pages
          end
        end
      end
    end
  end
end
