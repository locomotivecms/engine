# encoding: utf-8

class ThemeAssetUploader < AssetUploader

  process :set_content_type
  process :set_size
  process :set_width_and_height

  # version :thumb do
  #   process :resize_to_fill => [50, 50]
  #   process :convert => 'png'
  # end
  #
  # version :medium do
  #   process :resize_to_fill => [80, 80]
  #   process :convert => 'png'
  # end
  #
  # version :preview do
  #   process :resize_to_fit => [880, 1100]
  #   process :convert => 'png'
  # end

  def store_dir
    File.join('sites', model.site_id.to_s, 'theme', model.folder)
    # File.join('sites', model.site_id.to_s, 'theme', model.content_type.pluralize, model.subfolder || '')

    # base = File.join('sites', model.site_id.to_s, 'theme')
    # # puts "base = #{base} / #{model.subfolder.inspect}"
    # if model.subfolder.blank?
    #   File.join(base, model.content_type.pluralize)
    # else
    #   File.join(base, model.subfolder)
    # end

    #
    # # "sites/#{model.site_id}/themes/#{model.id}/#{model.content_type.pluralize}"
    # File.join("sites/#{model.site_id}/theme", model.subfolder || '', model.content_type.pluralize)
  end

  def extension_white_list
    %w(jpg jpeg gif png css js swf flv eot svg ttf woff)
  end

end
