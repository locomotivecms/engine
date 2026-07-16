module Locomotive
  module Concerns
    module Account

      # More information here: https://github.com/mongoid/mongoid/issues/3626
      module APIKey

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

          # Issue the account's authentication token, identifying the account by its
          # email/password pair or by its api_key.
          #
          # @param  [ String ] email    The account email
          # @param  [ String ] password The account password
          # @param  [ String ] api_key  The account API key
          #
          # @return [ String ] The account authentication token
          # @raise  [ Account::AuthenticationError ] if the credentials do not authenticate
          #
          def create_api_token(email, password, api_key)
            if api_key.present?
              account = self.where(api_key: api_key).first

              raise Locomotive::Account::AuthenticationError, 'invalid API key' if account.nil?
            elsif email.present? && password.present?
              account = self.where(email: email.downcase).first

              raise Locomotive::Account::AuthenticationError, 'invalid email or password' if account.nil? || !account.valid_password?(password)
            else
              raise Locomotive::Account::AuthenticationError, 'missing credentials'
            end

            account.ensure_authentication_token
            account.save

            account.authentication_token
          end

        end

      end
    end
  end
end
