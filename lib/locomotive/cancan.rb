module Locomotive
  module Api
    module CanCan

      class ControllerResource < ::CanCan::ControllerResource

        def build_resource
          # FIXME: within the API scope, we do not have to pass directly the params
          # to the new instance because we use presenters instead.
          resource = resource_base.new
          resource.send("#{parent_name}=", parent_resource) if @options[:singleton] && parent_resource
          initial_attributes.each do |attr_name, value|
            resource.send("#{attr_name}=", value)
          end
          resource
        end

      end

    end
  end
end