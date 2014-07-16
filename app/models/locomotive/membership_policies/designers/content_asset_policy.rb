module Locomotive
  module MembershipPolicies
    module Designers
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
