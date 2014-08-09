# encoding: utf-8

module Locomotive
  class PictureUploader < ::CarrierWave::Uploader::Base

    include ::CarrierWave::MimeTypes

    def extension_white_list
      %w(jpg jpeg gif png)
    end

    def image?
      self.file ? self.file.content_type : false
    end

  end
end