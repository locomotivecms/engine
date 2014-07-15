module Locomotive
  module MembershipPolicies
    module Guest
      class AccountScope < Locomotive::MembershipPolicies::AbstractScope

        def resolve
          []
        end
      end
    end
  end
end
