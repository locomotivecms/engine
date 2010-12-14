module Admin::AssetsHelper

  def vignette_tag(asset)
    image_tag(asset.vignette_url)
  end

  def image_dimensions_and_size(asset)
    content_tag(:small, "#{asset.width}px x #{asset.height}px | #{number_to_human_size(asset.size)}")
  end

  def allow_plain_text_editing?(asset)
    asset.new_record? || asset.stylesheet? || asset.javascript?
  end

end
