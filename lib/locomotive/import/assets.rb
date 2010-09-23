module Locomotive
  module Import
    module Assets

      def self.process(context)
        site, theme_path = context[:site], context[:theme_path]

        self.add_theme_assets(site, theme_path)

        self.add_other_assets(site, theme_path)
      end

      def self.add_theme_assets(site, theme_path)
        %w(images stylesheets javascripts).each do |kind|
          Dir[File.join(theme_path, 'public', kind, '*')].each do |asset_path|

            next if File.directory?(asset_path)

            slug = File.basename(asset_path, File.extname(asset_path)).parameterize('_')

            asset = site.theme_assets.where(:content_type => kind.singularize, :slug => slug).first
            asset ||= site.theme_assets.build

            asset.attributes = { :source => File.open(asset_path), :performing_plain_text => false }
            asset.save!

            site.reload
            # asset.reload
            #
            # puts "asset.url = #{asset.source.url}"
            #
            # # asset = site.theme_assets.create! :source => File.open(asset_path), :performing_plain_text => false
            # # puts "#{asset.source.inspect} / #{asset.inspect}\n--------\n"
          end
        end
      end

      def self.add_other_assets(site, theme_path)
        collection = AssetCollection.find_or_create_internal(current_site)

        Dir[File.join(theme_path, 'public', 'samples', '*')].each do |asset_path|

          next if File.directory?(asset_path)

          name = File.basename(asset_path, File.extname(asset_path)).parameterize('_')

          collection.assets.create! :name => name, :source => File.open(asset_path)
        end
      end

    end
  end
end