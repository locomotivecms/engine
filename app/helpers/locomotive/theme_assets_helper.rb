module Locomotive::ThemeAssetsHelper

  def image_dimensions_and_size(asset)
    content_tag(:small, "#{asset.width}px x #{asset.height}px | #{number_to_human_size(asset.size)}")
  end

  def plain_text_type(asset)
    asset.size && asset.size > 40000 ? 'nude' : (asset.content_type || 'stylesheet')
  end

  def allow_plain_text_editing?(asset)
    asset.new_record? || asset.stylesheet_or_javascript?
  end

  def display_plain_text?(asset)
    if asset.new_record?
      asset.performing_plain_text?
    else
      asset.stylesheet_or_javascript?
    end
  end


end