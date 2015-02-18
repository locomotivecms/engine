module Locomotive

  # Sets up model/repository methods.
  # @example
  #
  # def translation_params
  #   permitted_params[:translation]
  # end
  #
  # def auth(meth)
  #   authorize Translation, meth
  # end
  #
  # def translations
  #   current_site.translations
  # end
  #
  # def translation
  #   @translation ||= translations.find(params[:id])
  # end
  #
  module RepositoryHelper

    attr_accessor :repository_klass, :use_form_object

    def setup_methods_for(repository_klass, opts = {})
      self.repository_klass = repository_klass
      self.use_form_object = opts[:use_form_object]

      setup_plural_method
      setup_singular_method
      setup_params_method
      setup_auth_method
      setup_object_auth_method
      setup_form_method if use_form_object?
    end

    private

    def use_form_object?
      use_form_object
    end

    def singular
      @singular ||= repository_klass.name.demodulize.underscore
    end

    def plural
      @plural ||= singular.pluralize
    end

    def setup_params_method
      self.class.send(:define_method, "#{singular}_params") do
        permitted_params[singular.to_sym]
      end
    end

    # Authenticate an action against a class
    def setup_auth_method
      self.class.send(:define_method, :auth) do |meth|
        authorize repository_klass, meth
      end
    end

    # Authenticate an action against an instance
    def setup_object_auth_method
      self.class.send(:define_method, :object_auth) do |meth|
        authorize send(singular), meth
      end
    end

    def setup_form_method
      self.class.send(:define_method, "#{singular}_form") do
        unscoped_class = "#{singular}_form".classify
        "Locomotive::#{unscoped_class}".constantize
      end
    end

    def setup_plural_method
      self.class.send(:define_method, plural) do
        current_site.send(plural)
      end
    end

    def setup_singular_method
      self.class.send(:define_method, singular) do
        instance_variable = "@#{singular}"
        if instance_variable_defined?(instance_variable)
          instance_variable_get(instance_variable)
        else
          instance_variable_set(instance_variable, send(plural).find(params[:id]))
        end
      end
    end

  end
end
