puts "...loading Locomotive engine"

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

    initializer "Locomotive precompile hook" do |app|
      # app.config.assets.precompile += %w(locomotive.js locomotive.css locomotive/inline_editor.js locomotive/inline_editor.css
      # locomotive/not_logged_in.js locomotive/not_logged_in.css
      # locomotive/aloha.js)

      app.config.assets.precompile += %w(locomotive.js locomotive.css locomotive/inline_editor.js locomotive/inline_editor.css
      locomotive/not_logged_in.js locomotive/not_logged_in.css
      locomotive/aloha.js)

      def compile_asset?(path)
        # ignores any filename that begins with '_' (e.g. sass partials)
        # all other css/js/sass/image files are processed
        if File.basename(path) =~ /^[^_].*\.\w+$/
          puts "Compiling: #{path}"
          true
        else
          puts "Ignoring: #{path}"
          false
        end
      end

      app.config.assets.precompile = [ method(:compile_asset?).to_proc ]

      # app.config.assets.precompile += lambda { |f| puts f.inspect; true }

      # locomotive/aloha.js locomotive/aloha.css
      # locomotive/aloha/img/*)
      # # locomotive/utils/aloha_settings.js
      # # locomotive/aloha/*.js
      # # locomotive/aloha.css
      # # locomotive/aloha/plugins/*.css)
    end

  end
end
