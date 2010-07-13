module Locomotive
  class CopyAssetsGenerator < Rails::Generators::Base
  
    def self.source_root      
      @_locomotive_source_root ||= File.expand_path('../../../../../', __FILE__)
      @_locomotive_source_root
    end
  
    def copy_public_files
      directory 'public', 'public', :recursive => true
    end
  
  end
end