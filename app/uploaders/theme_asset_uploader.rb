# encoding: utf-8

class ThemeAssetUploader < AssetUploader

  process :set_content_type
  process :set_size
  process :set_width_and_height

  # after :store, :foo
  #
  #  def filename_was
  #    column = model.send(:_mounter, self.mounted_as).send(:serialization_column)
  #    model.send("#{column}_was")
  #  end
  #
  #  def filename_changed?
  #    column = model.send(:_mounter, self.mounted_as).send(:serialization_column)
  #    model.send("#{column}_changed?")
  #  end

  def store_dir
    File.join('sites', model.site_id.to_s, 'theme', model.folder_was || model.folder)
  end

  # def store_dir_was
  #   File.join('sites', model.site_id.to_s, 'theme', model.folder_was)
  # end
  #
  def stale_model?
    !model.new_record? && model.folder_changed?
  end
  #
  # def store_dir_was
  #   File.join('sites', model.site_id.to_s, 'theme', model.folder_was) rescue nil
  # end
  #
  # def store_dir_changed?
  #   self.store_dir_was && self.store_dir_was != self.store_dir
  # end
  #
  # def store_path_was(for_file=filename)
  #   File.join([store_dir_was, full_filename(for_file)].compact)
  # end
  #
  # def foo
  #   "store_dir_was = #{store_dir_was.inspect} / #{store_path_was}"
  # end

  def extension_white_list
    %w(jpg jpeg gif png css js swf flv eot svg ttf woff)
  end

end
