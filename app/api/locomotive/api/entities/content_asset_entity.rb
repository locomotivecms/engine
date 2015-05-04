module Locomotive
  module API
    module Entities

      class ContentAssetEntity < BaseEntity

        expose :content_type, :width, :height, :vignette_url, :alternative_vignette_url, :checksum

        expose :filename do |content_asset, _|
          truncate(content_asset.source_filename, length: 28)
        end

        expose :short_name do |content_asset, _|
          truncate(content_asset.name, length: 15)
        end

        expose :extname, format_with: :truncate_to_3

        expose :full_filename do |content_asset, _|
          content_asset.source_filename
        end

        expose :content_type_text do |content_asset, _|
         value = content_asset.content_type.to_s == 'other' ? content_asset.extname : content_asset.content_type
         value.blank? ? '?' : value
        end

        expose :with_thumbnail do |content_asset, _|
         %w(image pdf).include?(content_asset.content_type)
        end

        expose :raw_size do |content_asset, _|
         content_asset.size
        end

        expose :url do |content_asset, _|
          content_asset.source.url
        end

      end

    end
  end
end
