require 'locomotive/dependencies'
require 'locomotive'

$:.unshift File.dirname(__FILE__) # TODO: not sure about that, looks pretty useless

module Locomotive
  class Engine < Rails::Engine

    isolate_namespace Locomotive

    paths['mongodb/migrate'] = 'mongodb/migrate'

    initializer "locomotive.params.filter" do |app|
      # Do not log remote_<field>_url params because they can contain huge base64 string
      app.config.filter_parameters += [/\Aremote_.+_url\Z/]
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
      require 'locomotive/middlewares'

      app.middleware.use '::Locomotive::Middlewares::Site'
    end

    initializer 'steam' do |app|
      require 'locomotive/steam_adaptor'
    end

  end
end
