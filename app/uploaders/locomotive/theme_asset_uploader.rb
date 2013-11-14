# encoding: utf-8

module Locomotive
  class ThemeAssetUploader < ::CarrierWave::Uploader::Base

    include Locomotive::CarrierWave::Uploader::Asset

    def store_dir
      self.build_store_dir('sites', model.site_id, 'theme', model.folder)
    end

    def extension_white_list
      %w(jpg jpeg gif png css js swf flv eot svg ttf woff otf ico htc)
    end

    def self.url_for(site, path)
      build(site, path).url
    end

    def self.build(site, path)
      asset     = site.theme_assets.build(folder: File.dirname(path))
      uploader  = ThemeAssetUploader.new(asset)
      uploader.retrieve_from_store!(File.basename(path))
      uploader
    end

    def self.content_types
      # pdf is not considered as a custom content type for theme assets.
      list = super.clone
      list.delete(:pdf)
      list
    end

  end
end