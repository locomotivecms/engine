module Locomotive
  module API
    module Helpers
      module ParamsHelper

        def permitted_params
          @permitted_params ||= declared(params, include_missing: false)
        end

        # Much safer than permitted_params because it also uses the current policy
        # (Pundit) to filter the parameters.
        #
        # Example:
        #
        # permitted_params_from_policy(current_site, :site)
        #
        def permitted_params_from_policy(object_or_class, key)
          _params     = permitted_params[key]
          _attributes = policy(object_or_class).permitted_attributes
          ::ActionController::Parameters.new(_params).permit(*_attributes)
        end

      end

    end
  end
end
