class ThemeUploader < ::CarrierWave::Uploader::Base

  def store_dir
    "sites/#{model.id}/tmp/themes"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def extension_white_list
    %w(zip)
  end

end