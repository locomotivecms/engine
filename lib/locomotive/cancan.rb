module Locomotive
  module Api
    module CanCan

      class ControllerResource < ::CanCan::ControllerResource

        def build_resource
          raise Exception.new('No longer Locomotive::Api::CanCan::ControllerResource#build_resource')
        end

      end

    end
  end
end
