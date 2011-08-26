# Custom options for CustomFields
CustomFields.options = {
  :reserved_aliases => Mongoid.destructive_fields + %w(created_at updated_at)
}

# Set correct paths
module CustomFields
  module Types
    module File
      class FileUploader < ::CarrierWave::Uploader::Base

        def store_dir
          "sites/#{model.site_id}/contents/#{model.class.model_name.underscore}/#{model.id}/files"
        end

        def cache_dir
          "#{Rails.root}/tmp/uploads"
        end

      end
    end

    module Category
      class Item

        def to_liquid
          { 'id' => self._id.to_s, 'name' => self.name }
        end

      end
    end
  end
end

