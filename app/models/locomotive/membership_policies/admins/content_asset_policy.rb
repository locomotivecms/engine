module Locomotive
  module MembershipPolicies
    module Admins
      class ContentAssetPolicy < AbstractPolicy

        def create?
          true
        end
        
        def touch?
          true
        end

      end
    end
  end
end
