module Locomotive
  module MembershipPolicies
    module Admins

      class SitePolicy < Locomotive::MembershipPolicies::AbstractPolicy

        def touch?
          true
        end

        def create?
          false
        end

      end

    end
  end
end
