module Locomotive
  module Liquid
    module Filters
      module Resize

        def resize(input, resize_string)

          if input.is_a?(String)            # Path to image
            string_image_url(input, resize_string)
          elsif input.is_a?(Hash)           # Theme Image
            hash_image_url(input, resize_string)
          elsif input.respond_to?(:source)  # Liquid drop
            drop_image_url(input, resize_string)
          end

        end

        protected

        def app
          Dragonfly[:images]
        end

        # Returns the URL to a resized image given an image path
        def string_image_url(input, resize_string)
          path = "public/#{input}"
          app.fetch_file(path).thumb(resize_string).url
        end

        # Returns the URL to a resized images given a theme asset
        def hash_image_url(input, resize_string)

          theme_asset = @context.registers[:site].theme_assets.where(:_id => input['_id'].to_s).first
          if theme_asset.present?
            path = theme_asset.source.current_path
            app.fetch_file(path).thumb(resize_string).url
          end
        end

        # Returns the URL to a resized image given a liquid drop
        # that contains an uploader
        def drop_image_url(input, resize_string)
          uploader = input.source.try(:source)
          if uploader.present?
            if uploader.class.storage == CarrierWave::Storage::File
              # Local file storage
              path = uploader.current_path
              app.fetch_file(path).thumb(resize_string).url
            else
              # Cloud storage
              url = uploader.url
              app.fetch_url(url).thumb(resize_string).url
            end
          end
        end

      end

      ::Liquid::Template.register_filter(Resize)

    end
  end
end
