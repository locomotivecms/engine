module Locomotive
  module Middlewares
    class InlineEditor

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        response = @app.call(env)

        unless response[1]['Editable'].blank?
           html = response.last.body.to_s.gsub '</body>', %(
            <a  href="_admin"
                onmouseout="this.style.backgroundPosition='0px 0px'"
                onmouseover="this.style.backgroundPosition='0px -45px'"
                onmousedown="this.style.backgroundPosition='0px -90px'"
                onmouseup="this.style.backgroundPosition='0px 0px'"
                style="display: block;z-index: 1031;position: fixed;top: 10px; right: 10px;width: 48px; height: 45px;text-indent:-9999px;text-decoration:none;background: transparent url\('/assets/locomotive/icons/start.png'\) no-repeat 0 0;">
            Admin</a>
            </body>
           )
           [response[0], response[1], [html]]
        else
          response
        end
      end

    end
  end
end