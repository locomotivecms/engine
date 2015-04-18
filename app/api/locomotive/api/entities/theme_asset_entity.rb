module Locomotive
  module API
    module Entities

      class ThemeAssetEntity < BaseEntity

        expose :content_type, :folder, :checksum

        expose :local_path do |theme_asset, _|
          theme_asset.local_path(true)
        end

        expose :url do |theme_asset, _|
          theme_asset.source.url
        end

        expose :size, format_with: :human_size

        expose :width, if: :image?
        expose :height, if: :image?

        expose :raw_size do |theme_asset, _|
          theme_asset.size
        end

        private

        def image?
          object.image?
        end

      end

    end
  end
end
