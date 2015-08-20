module Locomotive
  module API
    module Entities

      class ThemeAssetEntity < BaseEntity

        expose :content_type, :local_path, :folder, :checksum

        expose :filename do |theme_asset, _|
          theme_asset.read_attribute(:source_filename)
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
