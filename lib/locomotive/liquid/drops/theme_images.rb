module Locomotive
  module Liquid
    module Drops
      class ThemeImages < ::Liquid::Drop

        def initialize(site)
          @site = site
        end

        def before_method(meth)
          asset = @site.theme_assets.where(:content_type => 'image', :slug => meth.to_s).first
          !asset.nil? ? asset.source.url : nil
        end

      end

    end
  end
end
