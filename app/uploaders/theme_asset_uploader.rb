# encoding: utf-8

class ThemeAssetUploader < AssetUploader

  process :set_content_type
  process :set_size
  process :set_width_and_height

  def store_dir
    File.join('sites', model.site_id.to_s, 'theme', model.folder_was || model.folder)
  end

  def stale_model?
    !model.new_record? && model.folder_changed?
  end

  def extension_white_list
    %w(jpg jpeg gif png css js swf flv eot svg ttf woff)
  end

end
