module CustomFields
  module Types
    module File
        
      extend ActiveSupport::Concern
      
      included do
        register_type :file, nil # do not create the default field
      end
    
      module InstanceMethods
        
        def apply_file_type(klass)
          
          klass.mount_uploader self._name, FileUploader

          self.apply_default_type(klass)
        end
          
      end
      
      class FileUploader < ::CarrierWave::Uploader::Base
      end
    
    end
  end
end