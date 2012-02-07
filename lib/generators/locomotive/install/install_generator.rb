module Locomotive
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path('../../../../../', __FILE__)

    def copy_initializers
      @source_paths = nil # reset it for the find_in_source_paths method

      Locomotive::InstallGenerator.source_root(File.expand_path('../templates', __FILE__))

      template 'locomotive.rb', 'config/initializers/locomotive.rb'

      template 'carrierwave.rb', 'config/initializers/carrierwave.rb'

      template 'dragonfly.rb', 'config/initializers/dragonfly.rb'

      template 'mongoid.yml', 'config/mongoid.yml'
    end

    def insert_engine_routes
      route %(
  mount Locomotive::Engine => '/locomotive', :as => 'locomotive' # you can change the value of the path, by default set to "/locomotive"
      )
    end

    def remove_index_html
      remove_file 'public/index.html'
    end

    def show_readme
      readme 'README'
    end

  end
end
