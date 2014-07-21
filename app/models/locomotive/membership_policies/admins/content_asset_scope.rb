module Locomotive
  module MembershipPolicies
    module Admins
      class ContentAssetScope < AbstractScope

        def resolve
          ContentAsset
        end
      end
    end
  end
end
