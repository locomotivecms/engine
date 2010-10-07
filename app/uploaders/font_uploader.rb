# encoding: utf-8

class FontUploader < CarrierWave::Uploader::Base

  def store_dir
    "sites/#{model.id}/theme/fonts"
  end

  def cache_dir
    "#{Rails.root}/tmp/uploads"
  end

end
