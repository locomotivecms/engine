module Locomotive
  module MembershipPolicies
    module Designers

      class SitePolicy < Locomotive::MembershipPolicies::AbstractPolicy

        def touch?
          self.record && self.record.memberships.include?(self.membership)
        end

        def create?
          false
        end

      end
    end
  end
end
