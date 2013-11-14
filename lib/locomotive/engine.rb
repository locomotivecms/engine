require 'locomotive/dependencies'
require 'locomotive'

$:.unshift File.dirname(__FILE__) # TODO: not sure about that, looks pretty useless

module Locomotive
  class Engine < Rails::Engine

    isolate_namespace Locomotive

    paths['mongodb/migrate'] = 'mongodb/migrate'
    # config.autoload_once_paths += %W( #{config.root}/app/controllers #{config.root}/app/models #{config.root}/app/helpers #{config.root}/app/uploaders)

    initializer 'locomotive.content_types' do |app|
      # Load all the dynamic classes (custom fields)
      begin
        ContentType.all.collect { |content_type| content_type.klass_with_custom_fields(:entries) }
      rescue Exception => e
        # let assume it's because of the first install (meaning no config.yml file)
        Locomotive.log :warn, "WARNING: unable to load the content types, #{e.message}"
      end
    end

    initializer 'locomotive.cells' do |app|
      Cell::Base.prepend_view_path("#{config.root}/app/cells")
    end

    initializer 'locomotive.action_controller' do |app|
      ::ActionController::Base.wrap_parameters format: [:json]
    end

    initializer 'locomotive.devise' do |app|
      ::DeviseController.respond_to :html, :json
    end

    initializer "locomotive.precompile.hook", group: :all do |app|
      app.config.assets.precompile += %w(
        locomotive.js
        locomotive.css
        locomotive/inline_editor.js
        locomotive/inline_editor.css
        locomotive/not_logged_in.js
        locomotive/not_logged_in.css
        locomotive/aloha.js
        tinymce/plugins/jqueryinlinepopups/editor_plugin.js
        tinymce/plugins/locomotive_media/*.js
        tinymce/plugins/locomotive_media/langs/*.js
        tinymce/themes/advanced/skins/locomotive/*.css
        aloha/plugins/custom/locomotive_media/**/*.css
        aloha/plugins/custom/locomotive_media/**/*.js
        aloha/plugins/custom/inputcontrol/**/*.css
        aloha/plugins/custom/inputcontrol/**/*.js)

      # Uncomment the lines below to view the names of assets as they are
      # precompiled for the rails asset pipeline
      # def compile_asset?(path)
      #   puts "Compiling: #{path}"
      #   true
      # end

      #app.config.assets.precompile = [ method(:compile_asset?).to_proc ]
    end

  end
end