module Locomotive
  module Liquid
    module Drops

      class AssetCollections < ::Liquid::Drop

        def initialize(site)
          @site = site
        end

        def before_method(meth)
          @site.asset_collections.where(:slug => meth.to_s)
        end

      end

    end
  end
end
