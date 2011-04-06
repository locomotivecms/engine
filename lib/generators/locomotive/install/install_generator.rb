module Locomotive
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path('../../../../../', __FILE__)

    def copy_mongoid_config
      copy_file 'config/mongoid.yml', 'config/mongoid.yml'
    end

    def copy_assets
      directory 'public', 'public', :recursive => true
      copy_file 'config/assets.yml', 'config/assets.yml'
    end

    def copy_initializers
      @source_paths = nil # reset it for the find_in_source_paths method

      Locomotive::InstallGenerator.source_root(File.expand_path('../templates', __FILE__))

      template 'locomotive.rb', 'config/initializers/locomotive.rb'

      template 'carrierwave.rb', 'config/initializers/carrierwave.rb'
    end

    def remove_index_html
      remove_file 'public/index.html'
    end

    def show_readme
      readme 'README'
    end

  end
end
