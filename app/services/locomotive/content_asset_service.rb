module Locomotive
  class ContentAssetService

    def initialize(site)
      @site = site
    end

    def list(options = {})
      options[:per_page] ||= Locomotive.config.ui[:per_page]

      @site.content_assets
        .ordered
        .by_content_types(options[:types])
        .by_filename(options[:query])
        .page(options[:page] || 1).per(options[:per_page])
    end

    def bulk_create(list)
      list = list.values if list.is_a?(Hash)
      list.map do |params|
        Locomotive::ContentAsset.new(params) # DEBUG: create
      end
    end

  end
end
