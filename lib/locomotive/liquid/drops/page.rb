module Locomotive
  module Liquid
    module Drops
      class Page < Base

        delegate :seo_title, :meta_keywords, :meta_description, :to => '_source'

        def title
          self._source.templatized? ? @context['entry']._label : self._source.title
        end

        def slug
          self._source.templatized? ? @context['entry']._slug.singularize : self._source.slug
        end

        def parent
          @parent ||= self._source.parent.to_liquid
        end

        def breadcrumbs
          @breadcrumbs ||= liquify(*self._source.ancestors_and_self)
        end

        def children
          @children ||= liquify(*self._source.children)
        end

        def fullpath
          @fullpath ||= self._source.fullpath
        end

        def depth
          self._source.depth
        end

        def listed?
          self._source.listed?
        end

        def published?
          self._source.published?
        end

        def before_method(meth)
          self._source.editable_elements.where(:slug => meth).try(:first).try(:content)
        end

      end
    end
  end
end
