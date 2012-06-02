# Custom options for CustomFields
CustomFields.options = {
  :reserved_names => Mongoid.destructive_fields + %w(created_at updated_at)
}

module CustomFields

  class Field
    field :ui_enabled, :type => Boolean, :default => true

    def class_name_to_content_type
      self._parent.send :class_name_to_content_type, self.class_name
    end

    protected

    def ensure_class_name_security
      self._parent.send :ensure_class_name_security, self
    end
  end

  module Types

    module File

      class FileUploader < ::CarrierWave::Uploader::Base

        # Set correct paths
        def store_dir
          "sites/#{model.site_id}/content_#{model.class.model_name.demodulize.underscore}/#{model.id}/files"
        end

        def cache_dir
          "#{Rails.root}/tmp/uploads"
        end

      end

    end

  end
end

