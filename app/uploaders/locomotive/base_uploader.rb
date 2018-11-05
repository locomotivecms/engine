# encoding: utf-8

module Locomotive
  class BaseUploader < ::CarrierWave::Uploader::Base
    include ::CarrierWave::ImageOptim

    if Locomotive.config.optimize_uploaded_files
      process optimize: [{
        gifsicle:   true,
        jpegoptim:  { allow_lossy: true, max_quality: 75 },
        optipng:    { level: 4 }
      }]
    end

  end
end
