# Set correct paths
module CustomFields
  module Types
    module File
      class FileUploader < ::CarrierWave::Uploader::Base

        def store_dir
          "sites/#{model.content_type.site_id}/contents/#{model.id}/files"
        end

        def cache_dir
          "#{Rails.root}/tmp/uploads"
        end

      end
    end
  end
end
