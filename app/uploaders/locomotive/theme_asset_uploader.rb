# encoding: utf-8

module Locomotive
  class ThemeAssetUploader < BaseUploader

    include Locomotive::CarrierWave::Uploader::Asset

    def store_dir
      self.build_store_dir('sites', model.site_id, 'theme', model.folder)
    end

    def extension_whitelist
      %w(jpg jpeg gif png css js swf flv mp4 eot svg svgz ttf ttc woff woff2 otf ico htc map html cur txt xml json ogv webm)
    end

    def apply_content_type_exception(value)
      if content_type == 'image/svg+xml' && model.folder.starts_with?('fonts')
        :font
      else
        value
      end
    end

    def self.content_types
      # pdf is not considered as a custom content type for theme assets.
      list = super.clone
      list.delete(:pdf)
      list
    end

  end
end
