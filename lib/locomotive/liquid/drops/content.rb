module Locomotive
  module Liquid
    module Drops
      class Content < Base

        delegate :seo_title, :meta_keywords, :meta_description, :to => '_source'

        def _id
          self._source._id.to_s
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
          end
        end

        def highlighted_field_value
          self._source.highlighted_field_value
        end

      end
    end
  end
end
