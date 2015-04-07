module Locomotive
  module API
    module Resources

      class TokenResource < Grape::API

        resource :tokens do
          desc 'Create session token'
          params do
            requires :email, type: String, desc: 'Your Email address.'
          end
          post do
            begin
              token = Account.create_api_token(params[:email], params[:password], params[:api_key])
              { token: token }
            rescue Exception => e
              response = { message: e.message }
              error! response, 401, 'X-Error-Detail' => e.message
            end
          end

          # stub destroy Account#invalidate_api_token(token)
        end

      end

    end
  end
end
