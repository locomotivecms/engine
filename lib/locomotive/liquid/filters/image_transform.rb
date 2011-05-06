module Locomotive
  module Liquid
    module Filters
      module Imagetransform

        def transform(input, transform_string)
          input
        end

      end

      ::Liquid::Template.register_filter(Imagetransform)

    end
  end
end
