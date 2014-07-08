module Locomotive
  module MembershipPolicies
    module Admins
      class SiteScope < Locomotive::MembershipPolicies::AbstractScope

        def resolve
          Site
        end
      end
    end
  end
end
