module Locomotive
  module ContentAssetsHelper

    def image_resize_form(content_asset)
      Locomotive::ImageResizeForm.new(
        width:  content_asset.width,
        height: content_asset.height
      )
    end

  end

  class ImageResizeForm
    include ActiveModel::Model
    attr_accessor :width, :height
  end
end
