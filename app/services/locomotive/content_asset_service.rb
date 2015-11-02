module Locomotive
  class ContentAssetService < Struct.new(:site, :account)

    include Locomotive::Concerns::ActivityService

    def list(options = {})
      options[:per_page] ||= Locomotive.config.ui[:per_page]

      site.content_assets
        .ordered
        .by_content_types(options[:types])
        .by_filename(options[:query])
        .page(options[:page] || 1).per(options[:per_page])
    end

    def bulk_create(list)
      list = list.values if list.is_a?(Hash)

      assets = list.map do |params|
        site.content_assets.create(params)
      end

      valid_assets = assets.map { |a| a.errors.empty? ? { name: a.source_filename, url: a.source.url, image: a.image?, id: a._id } : nil }.compact
      track_activity 'content_asset.created_bulk', parameters: { assets: valid_assets } unless valid_assets.empty?

      assets
    end

    def destroy(asset)
      asset.destroy.tap do
        track_activity 'content_asset.destroyed', parameters: { name: asset.source_filename }
      end
    end

  end
end
