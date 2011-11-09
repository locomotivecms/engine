puts "...loading Locomotive engine"

module Locomotive
  class Engine < Rails::Engine

    isolate_namespace Locomotive

    config.autoload_once_paths += %W( #{config.root}/app/controllers #{config.root}/app/models #{config.root}/app/helpers #{config.root}/app/uploaders)

    # initializer 'locomotive.load_controllers_and_models' do |app|
    #   puts "[locomotive/initializer] locomotive.load_controllers_and_models"
    # end
    #
    # config.before_initialize do |app|
    #   puts "[locomotive/before_initialize] NOTHING IS INITIALIZED !!!!!"
    # end
    #
    # config.before_configuration do |app|
    #   puts "[locomotive/before_configuration] NOTHING IS INITIALIZED !!!!!"
    # end

    initializer 'locomotive.cells' do |app|
      Cell::Base.prepend_view_path("#{config.root}/app/cells")
    end

    rake_tasks do
      load "railties/tasks.rake"
    end

  end
end
