module Locomotive
  module Middlewares

    class CustomPublicExceptions < ActionDispatch::PublicExceptions

      def call(env)
        status = env['PATH_INFO'][1..-1]

        if status == '404' || status == '500'
          Locomotive::ErrorsController.action(:"error_#{status}").call(env)
        else
          super
        end
      end

    end

  end
end
