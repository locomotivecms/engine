module SimpleTokenAuthentication
  module ActsAsTokenAuthenticationHandlerMethods
    extend ActiveSupport::Concern

    # Please see https://gist.github.com/josevalim/fb706b1e933ef01e4fb6
    # before editing this file, the discussion is very interesting.

    included do
      private :authenticate_entity_from_token!
      private :header_token_name
      private :header_email_name

      # This is necessary to test which arguments were passed to sign_in
      # from authenticate_entity_from_token!
      # See https://github.com/gonzalo-bulnes/simple_token_authentication/pull/32
      ActionController::Base.send :include, Devise::Controllers::SignInOut if Rails.env.test?
    end

    # For this example, we are simply using token authentication
    # via parameters. However, anyone could use Rails's token
    # authentication features to get the token from a header.
    def authenticate_entity_from_token!
      # Set the authentication token params if not already present,
      # see http://stackoverflow.com/questions/11017348/rails-api-authentication-by-headers-token
      params_token_name = "#{entity_name.underscore}_token".to_sym
      params_email_name = "#{entity_name.singularize.underscore}_email".to_sym
      if token = params[params_token_name].blank? && request.headers[header_token_name]
        params[params_token_name] = token
      end
      if email = params[params_email_name].blank? && request.headers[header_email_name]
        params[params_email_name] = email
      end

      email = params[params_email_name].presence
      # See https://github.com/ryanb/cancan/blob/1.6.10/lib/cancan/controller_resource.rb#L108-L111
      entity = nil
      if entity_class.respond_to? "find_by"
        entity = email && entity_class.find_by(email: email)
      elsif entity_class.respond_to? "find_by_email"
        entity = email && entity_class.find_by_email(email)
      end

      # Notice how we use Devise.secure_compare to compare the token
      # in the database with the token given in the params, mitigating
      # timing attacks.
      if entity && Devise.secure_compare(entity.authentication_token, params[params_token_name])
        # Notice we are passing store false, so the entity is not
        # actually stored in the session and a token is needed
        # for every request. If you want the token to work as a
        # sign in token, you can simply remove store: false.
        sign_in entity, store: SimpleTokenAuthentication.sign_in_token
      end
    end

    # Private: Return the name of the header to watch for the token authentication param
    def header_token_name
      # if SimpleTokenAuthentication.header_names["#{@@entity.name.singularize.underscore}".to_sym].presence
      #   SimpleTokenAuthentication.header_names["#{@@entity.name.singularize.underscore}".to_sym][:authentication_token]
      # else
        "X-#{entity_name.camelize}-Token"
      # end
    end

    # Private: Return the name of the header to watch for the email param
    def header_email_name
      # if SimpleTokenAuthentication.header_names["#{@@entity.name.singularize.underscore}".to_sym].presence
      #   SimpleTokenAuthentication.header_names["#{@@entity.name.singularize.underscore}".to_sym][:email]
      # else
        "X-#{entity_name.camelize}-Email"
      # end
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
