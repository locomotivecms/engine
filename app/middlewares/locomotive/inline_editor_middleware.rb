module Locomotive
  class InlineEditorMiddleware

    def initialize(app, opts = {})
      @app = app
    end

    def call(env)
      response = @app.call(env)

      unless response[1]['Editable'].blank?
         html = response.last.body.to_s.gsub '</body>', %(
          <a href="_admin">Admin</a>
          </body>
         )
         [response[0], response[1], [html]]
      else
        response
      end
    end

  end

end
