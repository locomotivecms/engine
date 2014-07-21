module Locomotive
  module MembershipPolicies
    module Admins
      class ContentAssetScope < AbstractScope

        def resolve
          binding.pry
          ContentAsset
        end
      end
    end
  end
end
