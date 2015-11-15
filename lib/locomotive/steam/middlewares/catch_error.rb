module Locomotive
  module Steam
    module Middlewares

      class CatchError

        def initialize(app, opts = {})
          @app = app
        end

        def call(env)
          begin
            @app.call(env)
          rescue Exception => e
            handle_exception(e, env)
          end
        end

        protected

        def handle_exception(exception, env)
          # display the application error page if not in the back-office
          raise exception unless env['steam.live_editing']

          ActiveSupport::Notifications.instrument 'locomotive.site.rendering_error', {
            env:        env,
            exception:  exception
          }

          Rails.logger.error "[LiveEditing] " + exception.message + "\n\t" + exception.backtrace.join("\n\t")

          render_error_page
        end

        def render_error_page
          [200, {}, [%(
<html>
  <head>
    <link href="#{bootstrap_stylesheet_url}" rel="stylesheet" type="text/css" />
  </head>
  <body>
    <div class="container">
      <div class="row">
        <div class="col-md-12">
          <img src="#{train_image_url}">

          <div class="alert alert-danger" role="alert">
            <h4 class="text-center">
              We're sorry, but something went wrong.
            </h4>
            <p class="text-center">
              If you are the application owner check the logs for more information.
            </p>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
          )]]
        end

        def bootstrap_stylesheet_url
          ::ActionController::Base.helpers.stylesheet_url('locomotive/live_editing_error')
        end

        def train_image_url
          ::ActionController::Base.helpers.image_url('locomotive/deadend.png')
        end

      end

    end
  end
end



