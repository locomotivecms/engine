module Locomotive
  module MembershipPolicies
    module Guests
      class SiteScope < Locomotive::MembershipPolicies::AbstractScope
        def resolve
          self.user.sites
        end
      end
    end
  end
end
