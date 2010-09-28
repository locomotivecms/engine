module Locomotive
  module Liquid
    module Drops
      module ThemeAssets

        class Base < ::Liquid::Drop

          def before_method(meth)
            content_type = self.class.name.demodulize.underscore.singularize

            asset = ThemeAsset.new(:site => @context.registers[:site], :content_type => content_type)
            ThemeAssetUploader.new(asset).store_path(meth.gsub('__', '.'))
          end

        end

        class Images < Base; end

        class Javascripts < Base; end

        class Stylesheets < Base; end

      end

    end
  end
end
