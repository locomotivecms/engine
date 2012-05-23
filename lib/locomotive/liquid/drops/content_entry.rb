module Locomotive
  module Liquid
    module Drops
      class ContentEntry < Base

        delegate :_slug, :_permalink, :seo_title, :meta_keywords, :meta_description, :to => '_source'

        def _id
          self._source._id.to_s
        end

        def _label
          @_label ||= self._source._label
        end

        # Returns the next content for the parent content type.
        # If no content is found, nil is returned.
        #
        # Usage:
        #
        # {% if article.next %}
        # <a href="/articles/{{ article.next._permalink }}">Read next article</a>
        # {% endif %}
        #
        def next
          self._source.next.to_liquid
        end

        # Returns the previous content for the parent content type.
        # If no content is found, nil is returned.
        #
        # Usage:
        #
        # {% if article.previous %}
        # <a href="/articles/{{ article.previous._permalink }}">Read previous article</a>
        # {% endif %}
        #
        def previous
          self._source.previous.to_liquid
        end

        def before_method(meth)
          return '' if self._source.nil?

          if not @@forbidden_attributes.include?(meth.to_s)
            value = self._source.send(meth)

            if value.respond_to?(:all) # check for an association
              filter_and_order_list(value)
            else
              value
            end
          else
            nil
          end
        end

        protected

        def filter_and_order_list(list)
          # filter ?
          if @context['with_scope']
            conditions  = HashWithIndifferentAccess.new(@context['with_scope'])
            order_by    = conditions.delete(:order_by).try(:split)

            list.filtered(conditions, order_by)
          else
            # no filter, default order
            list.ordered
          end
        end

      end
    end
  end
end
