module Locomotive
  module Liquid
    module Drops
      class Content < Base

        delegate :seo_title, :meta_keywords, :meta_description, :to => '_source'

        def _id
          self._source._id.to_s
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
