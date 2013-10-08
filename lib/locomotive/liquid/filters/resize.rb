module Locomotive
  module Liquid
    module Filters
      module Resize

        def resize(input, resize_string)
          source = input.instance_variable_get(:@_source) || input

          Locomotive::Dragonfly.resize_url(source, resize_string)
        end

      end

      ::Liquid::Template.register_filter(Resize)

    end
  end
end
