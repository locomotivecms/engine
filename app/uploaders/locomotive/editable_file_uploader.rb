# encoding: utf-8

module Locomotive
  class EditableFileUploader < ::CarrierWave::Uploader::Base

    include ::CarrierWave::MimeTypes

    process :set_content_type

    def store_dir
      self.build_store_dir('sites', model.page.site_id, 'pages', model.page.id, 'files')
    end

    def image?
      self.file ? self.file.content_type : false
    end

  end
end
