module Locomotive
  module Middlewares
    class ImageThumbnail

      PATH = '_image_thumbnail'

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] == self.class.route
          request = Rack::Request.new(env)

          image, format = request.params['image'], request.params['format']

          if thumb = make_thumb(image, format)
            respond(thumb)
          else
            respond('', 422)
          end
        else
          @app.call(env)
        end

      end

      def self.route
        Locomotive.mounted_on + '/' + PATH
      end

      private

      def make_thumb(image, format)
        return nil if image.blank? || format.blank?

        file = Locomotive::Dragonfly.app.fetch_url(image)

        begin
          if image.starts_with?('data') # base64
            file.apply.content.process!(:thumb, format).b64_data
          else
            file.thumb(format).url
          end
        rescue ArgumentError => e
          Locomotive.log "[image thumbnail] error = #{e.message}"
          nil
        end
      end

      def respond(response = '', status = 200)
        [status, { 'Content-Type' => 'text/plain' }, [response]]
      end

    end
  end
end
