module Locomotive
  module MembershipPolicies
    module Designers
      class AccountPolicy < Locomotive::MembershipPolicies::AbstractPolicy

        def touch?
          user == record # Can modify your account
        end

      end
    end
  end
end
