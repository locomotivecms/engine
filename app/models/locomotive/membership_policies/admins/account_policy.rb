module Locomotive
  module MembershipPolicies
    module Admins
      class AccountPolicy < Locomotive::MembershipPolicies::AbstractPolicy

        def touch?
          true
        end

      end
    end
  end
end
