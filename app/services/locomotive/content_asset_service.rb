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

    def create(params)
      create_or_update(params)
    end

    def bulk_create(list)
      list = list.values if list.is_a?(Hash)

      assets = list.map { |params| create_or_update(params) }
        
      valid_assets = assets.map { |a| a.errors.empty? ? { name: a.source_filename, url: a.source.url, image: a.image?, id: a._id } : nil }.compact
      track_activity 'content_asset.created_bulk', parameters: { assets: valid_assets } unless valid_assets.empty?

      assets
    end

    def destroy(asset)
      asset.destroy.tap do
        track_activity 'content_asset.destroyed', parameters: { name: asset.source_filename }
      end
    end

    private

    def create_or_update(params)
      return site.content_assets.create(params) unless site.overwrite_same_content_assets?

      asset = site.content_assets.build(params)
      filename = asset.source.filename
      
      existing_asset = site.content_assets.by_exact_filename(filename).first      

      return asset.tap { asset.save } unless existing_asset       

      existing_asset.tap do 
        # can't find out another way to replace the file when it has the same filename        
        existing_asset.destroy

        # very important to keep the same asset id
        asset._id = existing_asset._id
        asset.save
      end      
    end
  end
end
