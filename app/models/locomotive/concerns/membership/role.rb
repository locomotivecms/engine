module Locomotive
  module Concerns
    module Membership
      module Role

        extend ActiveSupport::Concern
        
        included do
            
        end

        def to_role
          role_name.to_sym
        end

        def role_name
          self.role.try(:name).to_s
        end

        def role_name=(role)
          self.role.name = role
        end

      end
    end
  end
end