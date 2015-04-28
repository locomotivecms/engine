module Locomotive
  module API
    module Helpers

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
      module PersistenceHelper

        attr_accessor :resource_name, :use_form_object

        def setup_resource_methods_for(resource_name)
          self.resource_name = resource_name.to_s

          setup_plural_method
          setup_singular_getter_method
          setup_singular_setter_method
          setup_params_method

          setup_object_auth_method
        end

        # @return [Class] a class constant for the matching form class.
        def form_klass
          namespaced_klass("#{singular}_form")
        end

        # @param [Object] the object to send to the policy class.  Leave empty for
        #  the singular (default) object to be sent.
        # @return [Class] a class constant for the current Pundit policy on the object.
        def current_policy(obj = nil)
          obj = obj ? obj : send(singular)
          policy_klass.new(pundit_user, obj)
        end

        # @param [Object] an object that responds to #serializable_hash is fed into
        #  the persistence class and save is called.
        # @note if the object exists it will be updated
        def persist_from_form(form_object)
          send(singular).assign_attributes(form_object.serializable_hash)
          send(singular).save!
        end

        def auth(meth)
          authorize persistence_klass, meth
        end

        private

        def policy_klass
          namespaced_klass("#{singular}_policy")
        end

        def persistence_klass
          # Change unscoped class to whatever repository/persistence class needed.
          namespaced_klass(singular)
        end

        def namespaced_klass(klass_name)
          un_namespaced_klass = klass_name.classify
          if un_namespaced_klass.ends_with?('Form')
            "Locomotive::API::Forms::#{un_namespaced_klass}"
          else
            "Locomotive::#{un_namespaced_klass}"
          end.constantize
        end

        def use_form_object?
          use_form_object
        end

        def singular
          @singular ||= plural.singularize
        end

        def plural
          @plural ||= resource_name
        end

        def setup_params_method
          self.class.send(:define_method, "#{singular}_params") do
            permitted_params[singular.to_sym]
          end
        end

        # Authenticate an action against an instance
        def setup_object_auth_method
          self.class.send(:define_method, :object_auth) do |meth|
            authorize send(singular), meth
          end
        end

        def setup_plural_method
          self.class.send(:define_method, plural) do
            current_site.send(plural)
          end
        end

        def setup_singular_getter_method
          self.class.send(:define_method, singular) do
            instance_variable = "@#{singular}"
            if instance_variable_defined?(instance_variable)
              instance_variable_get(instance_variable)
            else
              if params[:id]
                instance_variable_set(instance_variable, send(plural).find(params[:id]))
              else
                instance_variable_set(instance_variable, send(plural).new)
              end
            end
          end
        end

        def setup_singular_setter_method
          self.class.send(:define_method, "#{singular}=") do |var|
            instance_variable_set("@#{singular}", var)
          end
        end

      end

    end
  end
end
