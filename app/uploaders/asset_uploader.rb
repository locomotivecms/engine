# encoding: utf-8

class AssetUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  include Locomotive::CarrierWave::Uploader::Asset

  version :thumb, :if => :image? do
    process :resize_to_fill => [50, 50]
    process :convert => 'png'
  end

  version :medium, :if => :image? do
    process :resize_to_fill => [80, 80]
    process :convert => 'png'
  end

  version :preview, :if => :image? do
    process :resize_to_fit => [880, 1100]
    process :convert => 'png'
  end

  def store_dir
    self.build_store_dir('sites', model.collection.site_id, 'assets', model.id)
  end

end
