module Locomotive
  module MembershipPolicies
    module Authors
      class AccountPolicy < AbstractPolicy

        def touch?
          user == record # Can modify your account
        end

      end
    end
  end
end
