module Locomotive
  module ContentAssetsHelper

    def image_resize_form(content_asset)
      Locomotive::ImageResizeForm.new(
        width:  content_asset.width,
        height: content_asset.height
      )
    end

    def asset_with_thumbnail?(asset)
      %w(image pdf).include?(asset.content_type)
    end

    def asset_filename(asset)
      truncate(asset.source_filename, length: 28)
    end

    def asset_text(asset)
      extname = truncate(asset.extname, length: 3)
      value = asset.content_type.to_s == 'other' ? extname : asset.content_type
      value.blank? ? '?' : value
    end

    def human_asset_size(asset)
      if asset.image?
        "#{asset.width} X #{asset.height} px"
      else
        number_to_human_size(asset.size)
      end
    end

  end

  class ImageResizeForm
    include ActiveModel::Model
    attr_accessor :width, :height
  end
end
