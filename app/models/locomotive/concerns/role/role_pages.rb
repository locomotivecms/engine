module Locomotive
  module Concerns
    module Role
      module RolePages

        extend ActiveSupport::Concern

        included do
          field :role_pages,  type: ::RawArray, default: []
        end

        def role_pages_str=(pages_str)
          self.role_pages = pages_str.split(',')
        end

      end
    end
  end
end