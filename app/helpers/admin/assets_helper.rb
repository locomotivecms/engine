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
  
  def image_picker_include_tags
    html = javascript_include_tag 'admin/plugins/json2', 'admin/plugins/scrollTo', 'admin/plugins/codemirror/codemirror', 'admin/plugins/fancybox', 'admin/plugins/plupload/plupload.full', 'admin/plugins/imagepicker'
    html += stylesheet_link_tag 'admin/plugins/fancybox', 'admin/box'
    html
  end

end