class ThemeUploader < ::CarrierWave::Uploader::Base

  def store_dir
    if Locomotive.config.delayed_job
      "sites/#{model.id}/tmp/themes"
    else
      "#{Rails.root}/tmp/themes"
    end
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

  def extension_white_list
    %w(zip)
  end

end