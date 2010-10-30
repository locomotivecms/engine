module Locomotive
  module Import
    class Assets < Base

      def process
        whitelist = self.build_regexps_in_withlist(database['site']['assets']['whitelist']) rescue nil

        self.log "white list = #{whitelist.inspect}"

        self.add_theme_assets(whitelist)

        self.add_other_assets
      end

      protected

      def add_theme_assets(whitelist)
        %w(images media fonts javascripts stylesheets).each do |kind|
          Dir[File.join(theme_path, 'public', kind, '**/*')].each do |asset_path|

            next if File.directory?(asset_path)

            visible = self.check_against_whitelist(whitelist, asset_path.gsub(File.join(theme_path, 'public'), '').gsub(/^\//, ''))

            folder = asset_path.gsub(File.join(theme_path, 'public'), '').gsub(File.basename(asset_path), '').gsub(/^\//, '').gsub(/\/$/, '')

            asset = site.theme_assets.where(:local_path => File.join(folder, File.basename(asset_path))).first

            asset ||= site.theme_assets.build(:folder => folder)

            asset.attributes = { :source => File.open(asset_path), :performing_plain_text => false, :hidden => !visible }

            begin
              asset.save!
            rescue Exception => e
              self.log "!ERROR! = #{e.message}, #{asset_path}"
            end

            site.reload
          end
        end
      end

      def add_other_assets
        collection = AssetCollection.find_or_create_internal(site)

        Dir[File.join(theme_path, 'public', 'samples', '*')].each do |asset_path|

          next if File.directory?(asset_path)

          self.log "other asset = #{asset_path}"

          name = File.basename(asset_path, File.extname(asset_path)).parameterize('_')

          collection.assets.create! :name => name, :source => File.open(asset_path)
        end
      end

      def build_regexps_in_withlist(rules)
        rules.collect do |rule|
          if rule.start_with?('^')
            Regexp.new(rule.gsub('/', '\/'))
          else
            rule
          end
        end
      end

      def check_against_whitelist(whitelist, path)
        (whitelist || []).each do |rule|
          case rule
            when Regexp
              return true if path =~ rule
            when String
              return true if path == rule
          end
        end
        false
      end
    end
  end
end