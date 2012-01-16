module Locomotive
  class InlineEditorMiddleware

    def initialize(app, opts = {})
      @app = app
    end

    def call(env)
      response = @app.call(env)

      # if env['warden'].authenticated?(:locomotive_account) &&
      #    !env['PATH_INFO'].starts_with?("/assets") &&
      #    !env['PATH_INFO'].starts_with?("/#{Locomotive.mounted_on}/") &&
      #    !env['PATH_INFO'].ends_with?("/edit")

      Rails.logger.debug "headers = #{response[1].inspect}"

      unless response[1]['Editable'].blank?
         Rails.logger.debug "==> #{ENV['PATH_INFO'].inspect}, warden ? #{env['warden'].inspect} /#{env['warden'].user} / #{env['warden'].authenticated?(:locomotive_account)}"

         html = response.last.body.to_s.gsub '</body>', %(
          <a href="_edit">Edit</a>
          </body>
         )

         [response[0], response[1], [html]]
      else
        response
      end
    end

  end

end
