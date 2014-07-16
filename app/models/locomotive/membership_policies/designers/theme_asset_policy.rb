module Locomotive
  module MembershipPolicies
    module Designers
      class ThemeAssetPolicy < Locomotive::MembershipPolicies::AbstractPolicy

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
