module Locomotive
  module MembershipPolicies
    module Guest
      class AccountScope < AbstractScope

        def resolve
          []
        end
      end
    end
  end
end
