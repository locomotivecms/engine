module Locomotive
  module API
    module Entities

      class ThemeAssetEntity < BaseEntity

        expose :content_type, :folder, :checksum

        expose :plain_text, if: :plain_text?

        expose :local_path do |theme_asset, _|
          theme_asset.local_path(true)
        end

        expose :url do |theme_asset, _|
          theme_asset.source.url
        end

        expose :size, format_with: :human_size

        expose :dimensions do |theme_asset, _|
          "#{theme_asset.width}px x #{theme_asset.height}px" if theme_asset.image?
        end

        expose :plain_text  do |theme_asset, _|
          theme_asset.plain_text if plain_text?
        end

        expose :raw_size do |theme_asset, _|
          theme_asset.size
        end

        private

        def plain_text?
          options[:template] == 'update' && object.errors.empty? && object.stylesheet_or_javascript?
        end

      end

    end
  end
end
