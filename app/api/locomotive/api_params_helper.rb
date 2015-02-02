module Locomotive
  module APIParamsHelper
    def permitted_params
      @permitted_params ||= declared(params, include_missing: false)
    end
  end
end
