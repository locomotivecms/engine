# encoding: utf-8

module Locomotive
  class PictureUploader < BaseUploader

    def extension_whitelist
      %w(jpg jpeg gif png tiff)
    end

    def image?
      self.file.try(:exists?)
    end

    def store_dir
      self.build_store_dir('uploaded_assets', model.id)
    end

  end
end
