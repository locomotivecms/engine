# encoding: utf-8
require 'carrierwave-imageoptim'

module Locomotive
  class BaseUploader < ::CarrierWave::Uploader::Base
    include ::CarrierWave::ImageOptim

    process optimize: [{
      gifsicle: true,
      jpegoptim: { allow_lossy: true, max_quality: 75 },
      optipng: { level: 4 }
    }]
  end
end
