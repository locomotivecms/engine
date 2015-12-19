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

          file = Locomotive::Dragonfly.app.fetch_url(image)

          if image.blank? || format.blank?
            respond('', 422)
          elsif image.starts_with?('data') # base64
            respond(file.apply.content.process!(:thumb, format).b64_data)
          else
            respond(file.thumb(format).url) # url
          end
        else
          @app.call(env)
        end

      end

      def self.route
        Locomotive.mounted_on + '/' + PATH
      end

      private

      def respond(response = '', status = 200)
        [status, { 'Content-Type' => 'text/plain' }, [response]]
      end

    end
  end
end
