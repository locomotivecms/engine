require 'locomotive/liquid/drops/contents'

module Locomotive
  module Liquid
    module Drops

      class AssetCollections < Contents

        def before_method(meth)
          Rails.logger.warn "\n[WARNING] asset_collections is deprecated and will be removed in the next commits. Please, use contents.<slug> instead.\n\n"
          super(meth)
        end

      end

    end
  end
end
