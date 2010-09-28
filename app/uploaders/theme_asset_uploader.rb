# encoding: utf-8

class ThemeAssetUploader < AssetUploader

  process :set_content_type
  process :set_size
  process :set_width_and_height

  version :thumb do
    process :resize_to_fill => [50, 50]
    process :convert => 'png'
  end

  version :medium do
    process :resize_to_fill => [80, 80]
    process :convert => 'png'
  end

  version :preview do
    process :resize_to_fit => [880, 1100]
    process :convert => 'png'
  end

  def store_dir
    # "sites/#{model.site_id}/themes/#{model.id}"
    "sites/#{model.site_id}/theme/#{model.content_type.pluralize}"
  end

  def extension_white_list
    %w(jpg jpeg gif png css js swf flv)
  end

end
