module Locomotive
  module Liquid
    module Drops
      class Asset < Base

        def before_method(meth)
          return '' if @source.nil?

          if not @@forbidden_attributes.include?(meth.to_s)
            value = @source.send(meth)
          end
        end

        def url
          @source.source.url
        end

      end
    end
  end
end
