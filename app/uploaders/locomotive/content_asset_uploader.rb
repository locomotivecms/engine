# encoding: utf-8

module Locomotive
  class ContentAssetUploader < BaseUploader

    include Locomotive::CarrierWave::Uploader::Asset

    def store_dir
      self.build_store_dir('sites', model.site_id, 'assets', model.id)
    end

  end
end
