module Locomotive
  module Import
    class Assets < Base

      def process
        self.add_theme_assets

        self.add_content_assets
      end

      protected

      def add_theme_assets
        %w(images media fonts javascripts stylesheets).each do |type|
          Dir[File.join(theme_path, 'public', type, '**/*')].each do |asset_path|

            next if File.directory?(asset_path)

            folder = asset_path.gsub(File.join(theme_path, 'public'), '').gsub(File.basename(asset_path), '').gsub(/^\//, '').gsub(/\/$/, '')

            asset = site.theme_assets.where(:local_path => File.join(folder, File.basename(asset_path))).first

            asset ||= site.theme_assets.build(:folder => folder)

            asset.attributes = { :source => File.open(asset_path), :performing_plain_text => false }

            begin
              asset.save!
            rescue Exception => e
              self.log "!ERROR! = #{e.message}, #{asset_path}"
            end
          end
        end
      end

      def add_content_assets
        Dir[File.join(theme_path, 'public', 'samples', '*')].each do |asset_path|

          next if File.directory?(asset_path)

          self.log "other asset = #{asset_path}"

          asset = site.content_assets.where(:source_filename => File.basename(asset_path)).first

          asset ||= self.site.content_assets.build

          asset.attributes = { :source => File.open(asset_path) }

          begin
            asset.save!
          rescue Exception => e
            self.log "!ERROR! = #{e.message}, #{asset_path}"
          end
        end
      end

    end
  end
end