module Locomotive
  module MembershipPolicies
    module Admins
      class AccountScope < Locomotive::MembershipPolicies::AbstractScope

        def resolve
          Locomotive::Account
        end
      end
    end
  end
end