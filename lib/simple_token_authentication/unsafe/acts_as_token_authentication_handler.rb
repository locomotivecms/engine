module SimpleTokenAuthentication
  module ActsAsTokenAuthenticationHandlerMethods
    extend ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :authenticate_entity_from_token!
      private :header_token_name
      # This is our new function that comes before Devise's one
      before_filter :authenticate_entity_from_token!
      # This is Devise's authentication
      before_filter :authenticate_entity!

      # This is necessary to test which arguments were passed to sign_in
      # from authenticate_entity_from_token!
      # See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/32
      ActionController::Base.send :include, Devise::Controllers::SignInOut if Rails.env.test?
    end

    def authenticate_entity!
      # Caution: entity should be a singular camel-cased name but could be pluralized or underscored.
      self.method("authenticate_#{entity_name.underscore}!".to_sym).call
    end


    # For this example, we are simply using token authentication
    # via parameters. However, anyone could use Rails's token
    # authentication features to get the token from a header.
    def authenticate_entity_from_token!
      # Set the authentication token params if not already present,
      # see http://stackoverflow.com/questions/11017348/rails-api-authentication-by-headers-token
      params_token_name = :auth_token
      if (token = params[params_token_name]).blank? && request.headers[header_token_name]
        params[params_token_name] = token
      end
      # See https://github.com/ryanb/cancan/blob/1.6.10/lib/cancan/controller_resource.rb#L108-L111
      entity = nil

      entity   = token && entity_class.where(authentication_token: token.to_s).first
      if entity && Devise.secure_compare(entity.authentication_token, params[params_token_name])

        # Notice we are passing store false, so the entity is not
        # actually stored in the session and a token is needed
        # for every request. If you want the token to work as a
        # sign in token, you can simply remove store: false.
        sign_in entity, store: false
      end
    end

    # Private: Return the name of the header to watch for the token authentication param
    def header_token_name
        "X-#{entity_name.camelize}-Token"
    end

    def entity_name
      SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods.entity_name
    end

    def entity_class
      SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods.entity_class
    end

    class << self

      def entity_name
        @entity_class.name.singularize.parameterize
      end

      def set_entity_class entity_class
        @entity_class = entity_class
      end
      def entity_class
        @entity_class
      end
    end

  end

  module ActsAsTokenAuthenticationHandler
    extend ActiveSupport::Concern

    # I have insulated the methods into an additional module to avoid before_filters
    # to be applied by the `included` block before acts_as_token_authentication_handler_for was called.
    # See https://github.com/gonzalo-bulnes/simple_token_authentication/issues/8#issuecomment-31707201

    included do
      # nop
    end

    module ClassMethods
      def acts_as_token_authentication_handler_for(entity_class, options = {})
        SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods.set_entity_class entity_class
        include SimpleTokenAuthentication::ActsAsTokenAuthenticationHandlerMethods
      end

      def acts_as_token_authentication_handler
        ActiveSupport::Deprecation.warn "`acts_as_token_authentication_handler()` is deprecated and may be removed from future releases, use `acts_as_token_authentication_handler_for(User)` instead.", caller
        acts_as_token_authentication_handler_for User
      end
    end
  end
end
