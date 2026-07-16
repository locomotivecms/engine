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
            rescue Locomotive::Account::AuthenticationError
              error!({ error: 'Invalid credentials' }, 401)
            end
          end

        end

      end

    end
  end
end
