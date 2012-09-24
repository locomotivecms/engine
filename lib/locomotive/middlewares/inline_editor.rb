module Locomotive
  module Middlewares
    class InlineEditor

      def initialize(app, opts = {})
        @app = app
      end

      def call(env)
        status, headers, response = @app.call(env)

        response = modify(response) unless headers['Editable'].blank?

        [status, headers, response]
      end

      def modify(response)
        [].tap do |parts|
          response.each do |part|
            parts << part.to_s.gsub('</body>', %(
             <a  href="#{File.join(response.request.path, '/_admin')}"
                 onmouseout="this.style.backgroundPosition='0px 0px'"
                 onmouseover="this.style.backgroundPosition='0px -45px'"
                 onmousedown="this.style.backgroundPosition='0px -90px'"
                 onmouseup="this.style.backgroundPosition='0px 0px'"
                 style="display: block;z-index: 1031;position: fixed;top: 10px; right: 10px;width: 48px; height: 45px;text-indent:-9999px;text-decoration:none;background: transparent url\('/assets/locomotive/icons/start.png'\) no-repeat 0 0;">
             Admin</a>
             </body>
             ))
          end
        end
      end

    end
  end
end
