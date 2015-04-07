module Locomotive
  module API
    module Helpers
      module ParamsHelper

        def permitted_params
          @permitted_params ||= declared(params, include_missing: false)
        end

      end

    end
  end
end
