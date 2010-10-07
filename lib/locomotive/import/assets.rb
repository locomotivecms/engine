module Locomotive
  module Import
    module Assets

      def self.process(context)
        site, theme_path = context[:site], context[:theme_path]

        whitelist = self.build_regexps_in_withlist(context[:database]['site']['assets']['whitelist']) rescue nil

        puts "whitelist = #{whitelist.inspect}"

        self.add_theme_assets(site, theme_path, whitelist)

        # self.add_font_assets(site, theme_path)

        self.add_other_assets(site, theme_path)
      end

      def self.add_theme_assets(site, theme_path, whitelist)
        %w(images media fonts javascripts stylesheets).each do |kind|
          Dir[File.join(theme_path, 'public', kind, '**/*')].each do |asset_path|

            next if File.directory?(asset_path)

            visible = self.check_against_whitelist(whitelist, asset_path.gsub(File.join(theme_path, 'public'), ''))

            folder = asset_path.gsub(File.join(theme_path, 'public'), '').gsub(File.basename(asset_path), '').gsub(/^\//, '').gsub(/\/$/, '')
            # folder = nil if folder.blank? || folder == kind

            puts "folder = #{folder} / #{visible.inspect} / #{asset_path.gsub(File.join(theme_path, 'public'), '')} / local_path = #{File.join(folder, File.basename(asset_path))}"

            # slug = File.basename(asset_path, File.extname(asset_path)).parameterize('_')

            # asset = site.theme_assets.where(:content_type => kind.singularize, :folder => folder, :slug => slug).first

            asset = site.theme_assets.where(:local_path => File.join(folder, File.basename(asset_path))).first

            puts "found asset ! #{!asset.nil?} / #{File.join(folder, File.basename(asset_path))} / #{kind.singularize}"

            asset ||= site.theme_assets.build(:folder => folder)

            asset.attributes = { :source => File.open(asset_path), :performing_plain_text => false, :hidden => !visible }
            asset.save!

            puts "--------------------"

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

      # def self.add_font_assets(site, theme_path)
      #   uploader = FontUploader.new(site)
      #
      #   Dir[File.join(theme_path, 'public', 'fonts', '*')].each do |asset_path|
      #     next if File.directory?(asset_path)
      #     puts "font file = #{asset_path}"
      #     uploader.store!(File.open(asset_path))
      #   end
      # end

      def self.add_other_assets(site, theme_path)
        collection = AssetCollection.find_or_create_internal(site)

        Dir[File.join(theme_path, 'public', 'samples', '*')].each do |asset_path|

          next if File.directory?(asset_path)

          name = File.basename(asset_path, File.extname(asset_path)).parameterize('_')

          collection.assets.create! :name => name, :source => File.open(asset_path)
        end
      end

      def self.build_regexps_in_withlist(rules)
        rules.collect do |rule|
          if rule.start_with?('^')
            Regexp.new(rule.gsub('/', '\/'))
          else
            rule
          end
        end
      end

      def self.check_against_whitelist(whitelist, path)
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