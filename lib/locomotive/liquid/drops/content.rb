module Locomotive
  module Liquid
    module Drops
      class Content < Base
        delegate :meta_keywords, :meta_description, :to => '@source'

        def _id
          @source._id.to_s
        end

        def before_method(meth)
          return '' if @source.nil?

          if not @@forbidden_attributes.include?(meth.to_s)
            value = @source.send(meth)
          end
        end

        def highlighted_field_value
          @source.highlighted_field_value
        end

      end
    end
  end
end
