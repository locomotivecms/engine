require 'locomotive/dependencies'
require 'locomotive'

$:.unshift File.dirname(__FILE__) # TODO: not sure about that, looks pretty useless

module Locomotive
  class Engine < Rails::Engine

    isolate_namespace Locomotive

    # config.autoload_once_paths += %W( #{config.root}/app/controllers #{config.root}/app/models #{config.root}/app/helpers #{config.root}/app/uploaders)

    initializer 'locomotive.cells' do |app|
      Cell::Base.prepend_view_path("#{config.root}/app/cells")
    end

    initializer 'locomotive.action_controller' do |app|
      ::ActionController::Base.wrap_parameters :format => [:json]
    end

    initializer "Locomotive precompile hook", :group => :all do |app|
      app.config.assets.precompile += %w(locomotive.js locomotive.css locomotive/inline_editor.js locomotive/inline_editor.css
      locomotive/not_logged_in.js locomotive/not_logged_in.css
      locomotive/aloha.js)

      # Uncomment the lines below to view the names of assets as they are
      # precompiled for the rails asset pipeline
      #def compile_asset?(path)
        #puts "Compiling: #{path}"
        #true
      #end

      #app.config.assets.precompile = [ method(:compile_asset?).to_proc ]
    end

  end
end
