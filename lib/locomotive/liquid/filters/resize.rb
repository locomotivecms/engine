module Locomotive
  module Liquid
    module Filters
      module Resize

        def resize(input, resize_string)
          Locomotive::Dragonfly.resize_url(input, resize_string)
        end

      end

      ::Liquid::Template.register_filter(Resize)

    end
  end
end
