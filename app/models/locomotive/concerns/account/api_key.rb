module Locomotive
  module Concerns
    module Account

      # More information here: https://github.com/mongoid/mongoid/issues/3626
      module ApiKey

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :api_key

          ## callbacks ##
          before_validation :api_key_should_not_be_empty

        end

        # Regenerate the API key without saving the account.
        #
        # @return [ String ] The new api key
        #
        def regenerate_api_key
          self.api_key = Digest::SHA1.hexdigest("#{self._id}-#{Time.now.to_f}-#{self.created_at}")
        end

        # Regenerate the API key AND then save the account.
        #
        def regenerate_api_key!
          self.regenerate_api_key
          self.save
        end

        private

        def api_key_should_not_be_empty
          if self.api_key.blank?
            self.regenerate_api_key
          end
        end

        module ClassMethods

          # Create the API token which will be passed to all the requests to the Locomotive API.
          # It requires the credentials of an account with admin role OR the API key of the site.
          # If an error occurs (invalid account, ...etc), this method raises an exception that has
          # to be caught somewhere.
          #
          # @param [ String ] email The email of the account
          # @param [ String ] password The password of the account
          # @param [ String ] api_key The API key of the site.
          #
          # @return [ String ] The API token
          #
          def create_api_token(email, password, api_key)
            if api_key.present?
              account = self.where(api_key: api_key).first

              raise 'The API key is invalid.' if account.nil?
            elsif email.present? && password.present?
              account = self.where(email: email.downcase).first

              raise 'Invalid email or password.' if account.nil? || !account.valid_password?(password)
            else
              raise 'The request must contain either the user email and password OR the API key.'
            end

            account.ensure_authentication_token
            account.save

            account.authentication_token
          end

          # Logout the user responding to the token passed in parameter from the API.
          # An exception is raised if no account corresponds to the token.
          #
          # @param [ String ] token The API token created by the create_api_token method.
          #
          # @return [ String ] The API token
          #
          def invalidate_api_token(token)
            account = self.where(authentication_token: token).first

            raise 'Invalid token.' if account.nil?

            account.reset_authentication_token!

            token
          end

        end

      end
    end
  end
end
