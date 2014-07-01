module Locomotive
  module MembershipPolicies
    module Guests

      class SitePolicy < Locomotive::MembershipPolicies::AbstractPolicy

        def touch?
          false
        end

        def create?
          false
        end

      end

    end
  end
end
