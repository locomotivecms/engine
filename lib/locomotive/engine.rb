require 'locomotive/dependencies'
require 'locomotive'

$:.unshift File.dirname(__FILE__) # TODO: not sure about that, looks pretty useless

module Locomotive
  class Engine < Rails::Engine

    isolate_namespace Locomotive

    paths['mongodb/migrate'] = 'mongodb/migrate'
    # config.autoload_once_paths += %W( #{config.root}/app/controllers #{config.root}/app/models #{config.root}/app/helpers #{config.root}/app/uploaders)

    initializer 'steam' do |app|
      require 'locomotive/steam_adaptor'
    end

    initializer 'locomotive.content_types' do |app|
      # Load all the dynamic classes (custom fields)
      begin
        ContentType.all.collect { |content_type| content_type.klass_with_custom_fields(:entries) }
      rescue Exception => e
        # let assume it's because of the first install (meaning no config.yml file)
        Locomotive.log :warn, "WARNING: unable to load the content types, #{e.message}"
      end
    end

    initializer 'locomotive.action_controller' do |app|
      ::ActionController::Base.wrap_parameters format: [:json]
    end

    initializer 'locomotive.devise' do |app|
      ::DeviseController.respond_to :html, :json
    end

    initializer "locomotive.precompile.hook", group: :all do |app|
      app.config.assets.precompile += %w(
        locomotive/wysihtml5_reset.css
        locomotive/wysihtml5_editor.css
        locomotive.js
        locomotive.css
        locomotive/not_logged_in.js
        locomotive/not_logged_in.css)

      # Uncomment the lines below to view the names of assets as they are
      # precompiled for the rails asset pipeline
      # def compile_asset?(path)
      #   puts "Compiling: #{path}"
      #   true
      # end

      # app.config.assets.precompile = [ method(:compile_asset?).to_proc ]
    end

    initializer 'locomotive.middlewares' do |app|
      app.middleware.insert_before(Rack::Runtime, '::Locomotive::Middlewares::Permalink', nil)
      app.middleware.use '::Locomotive::Middlewares::Site'
    end

  end
end
