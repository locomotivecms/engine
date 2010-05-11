module Admin::AssetsHelper
  
  def vignette_tag(asset)
    if asset.image?
      if asset.width < 80 && asset.height < 80
        image_tag(asset.source.url)
      else
        image_tag(asset.source.url(:medium))
      end
    # elsif asset.pdf?
    #   image_tag(asset.source.url(:medium))
    else
      mime_type_to_image(asset, :medium)
    end    
  end
  
  def mime_type_to_image(asset, size = :thumb)
    mime_type = File.mime_type?(asset.source_filename)
    filename = "unknown"
    
    if !(mime_type =~ /pdf/).nil?
      filename = "PDF"
    elsif !(mime_type =~ /css/).nil?
      filename = "CSS"
    elsif !(mime_type =~ /javascript/).nil?
      filename = "JAVA"
    end
    
    image_tag(File.join("admin", "icons", "filetype", size.to_s, filename + ".png"))
  end
  
  def image_dimensions_and_size(asset)
    content_tag(:small, "#{asset.width}px x #{@asset.height}px | #{number_to_human_size(asset.size)}")
  end
  
  def allow_plain_text_editing?(asset)
    asset.new_record? || asset.stylesheet? || asset.javascript?
  end
  
end