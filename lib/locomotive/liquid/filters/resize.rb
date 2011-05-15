module Locomotive
  module Liquid
    module Filters
      module Resize

        def resize(input, resize_string)
          app  = Dragonfly[:images]
          path = input.respond_to?(:path) ? input.path : "public/#{input}"
          job  = app.fetch_file(path)
          job.thumb(resize_string).url
        end

        protected

      end

      ::Liquid::Template.register_filter(Resize)

    end
  end
end
