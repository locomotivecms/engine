# encoding: utf-8

class AssetUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  include Locomotive::CarrierWave::Uploader::Asset

  def store_dir
    self.build_store_dir('sites', model.site_id, 'assets', model.id)
  end

end
