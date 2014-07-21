module Locomotive
  module MembershipPolicies
    module Admins
      class AccountScope < AbstractScope

        def resolve
          Locomotive::Account
        end
      end
    end
  end
end
