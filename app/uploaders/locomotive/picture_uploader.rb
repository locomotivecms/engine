# encoding: utf-8

module Locomotive
  class PictureUploader < ::CarrierWave::Uploader::Base

    def extension_white_list
      %w(jpg jpeg gif png)
    end

  end
end