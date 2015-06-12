module Locomotive
  module Liquid
    module Drops
      class Page < Base

        delegate :seo_title, :meta_keywords, :meta_description, :redirect_url, :handle, :layout, to: :@_source

        def title
          title =  @_source.templatized? ? @context['entry'].try(:_label) : nil
          title || @_source.title
        end

        def slug
          slug = @_source.templatized? ? @context['entry'].try(:_slug).try(:singularize) : nil
          slug || @_source.slug
        end

        def original_title
          @_source.title
        end

        def original_slug
          @_source.slug
        end

        def parent
          @parent ||= @_source.parent.to_liquid
        end

        def breadcrumbs
          @breadcrumbs ||= liquify(*@_source.ancestors_and_self)
        end

        def children
          @children ||= liquify(*@_source.children)
        end

        def fullpath
          @fullpath ||= @_source.fullpath
        end

        def depth
          @_source.depth
        end

        def listed?
          @_source.listed?
        end

        def published?
          @_source.published?
        end

        def redirect?
          @_source.redirect?
        end

        def is_layout?
          @_source.is_layout?
        end

        def templatized?
          @_source.templatized?
        end

        def content_type
          if @_source.content_type
            ContentTypeProxyCollection.new(@_source.content_type)
          else
            nil
          end
        end

        def editable_elements
          @editable_elements_hash ||= build_editable_elements_hash
        end

        def before_method(meth)
          # @deprecated
          @_source.editable_elements.where(slug: meth).try(:first).try(:content)
        end

        private

        def build_editable_elements_hash
            {}.tap do |hash|
              @_source.editable_elements.each do |el|
                safe_slug = el.slug.parameterize.underscore
                keys      = el.block.try(:split, '/').try(:compact) || []

                _hash = _build_editable_elements_hashes(hash, keys)

                _hash[safe_slug] = el.content
              end
            end
          end

          def _build_editable_elements_hashes(hash, keys)
            _hash = hash

            keys.each do |key|
              safe_key = key.parameterize.underscore

              _hash[safe_key] = {} if _hash[safe_key].nil?

              _hash = _hash[safe_key]
            end

            _hash
          end

      end
    end
  end
end
