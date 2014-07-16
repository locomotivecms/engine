module Locomotive
  module MembershipPolicies
    module Admins
      class AccountPolicy < AbstractPolicy

        def touch?
          true
        end

      end
    end
  end
end
