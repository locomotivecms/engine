module Locomotive
  module Liquid
    module Drops
      class Stylesheets < ::Liquid::Drop

        def initialize(site)
          @site = site
        end

        def before_method(meth)
          @context.registers[:theme_uploader].store_path(meth.gsub('__', '.'))
          # asset = @site.theme_assets.where(:content_type => 'stylesheet', :slug => meth.to_s).first
          # !asset.nil? ? asset.source.url : nil
        end

      end

    end
  end
end
