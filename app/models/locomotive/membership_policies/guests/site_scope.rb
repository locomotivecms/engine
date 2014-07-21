module Locomotive
  module MembershipPolicies
    module Guests
      class SiteScope < AbstractScope

        def resolve
          self.user.sites
        end
      end
    end
  end
end
