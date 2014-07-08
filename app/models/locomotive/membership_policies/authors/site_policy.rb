module Locomotive
  module MembershipPolicies
    module Authors
      class SitePolicy < Locomotive::MembershipPolicies::AbstractPolicy

        def touch?
          self.record && self.record.memberships.include?(self.membership)
        end
      end
    end
  end
end
