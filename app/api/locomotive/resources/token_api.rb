module Locomotive
  module Resources
    class TokenAPI < Grape::API

      resource :token do
        desc 'Create session token'
        params do
          requires :email, type: String, desc: 'Your Email address.'
        end
        post do
          begin
            token = Account.create_api_token(params[:email], params[:password], params[:api_key])
            { token: token }
          rescue Exception => e
            logger.error "Unable to create a token, reason: #{e.message}"
            response = { message: e.message }
            error! response, 401, 'X-Error-Detail' => e.message
          end
        end

        # stub destroy Account#invalidate_api_token(token)
      end

    end
  end
end
