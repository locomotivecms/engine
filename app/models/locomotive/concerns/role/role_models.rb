module Locomotive
  module Concerns
    module Role
      module RoleModels

        extend ActiveSupport::Concern

        included do
          field :role_models, type: ::RawArray, default: []
        end

      end
    end
  end
end