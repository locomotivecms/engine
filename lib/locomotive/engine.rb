module Locomotive
  class Engine < ::Rails::Engine
    isolate_namespace Locomotive

    paths['mongodb/migrate'] = 'mongodb/migrate'

    # Allow the root app to change the behavior of Locomotive controllers and
    # models in a clean way.
    config.to_prepare do
      Dir.glob(Rails.root + 'app/decorators/**/*_decorator*.rb').each do |c|
        require_dependency(c)
      end
    end

    initializer 'locomotive.params.filter' do |app|
      # Do not log remote_<field>_url params because they can contain huge base64 string
      app.config.filter_parameters += [/\Aremote_.+_url\Z/]
    end

    initializer 'locomotive.action_controller' do |app|
      ::ActionController::Base.wrap_parameters format: [:json]
    end

    initializer 'locomotive.devise' do |app|
      ::DeviseController.respond_to :html, :json
    end

    initializer 'locomotive.assets' do |app|
      app.config.assets.paths << root.join('vendor', 'assets', 'components', 'locomotive')
    end

    initializer 'locomotive.precompile.hook', group: :all do |app|
      app.config.assets.precompile += %w(
        locomotive/icons/flags/*.png
        locomotive/*.png
        locomotive/*.gif
        locomotive/bootstrap-colorpicker/saturation.png
        locomotive/bootstrap-colorpicker/alpha-horizontal.png
        locomotive/bootstrap-colorpicker/alpha.png
        locomotive/bootstrap-colorpicker/hue-horizontal.png
        locomotive/bootstrap-colorpicker/hue.png
        locomotive/wysihtml5_reset.css
        locomotive/wysihtml5_editor.css
        locomotive.js
        locomotive.css
        locomotive/account.js
        locomotive/account.css
        locomotive/editor.js
        locomotive/editor.css
        locomotive/live_editing_iframe.css
        locomotive/live_editing_error.css
        locomotive/error.css)

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

      # Note: "insert 4" means inserting after Rack::Lock
      # specifying Rack::Lock caused an error in production.
      app.middleware.insert 4, ::Locomotive::Middlewares::ImageThumbnail
      app.middleware.use ::Locomotive::Middlewares::Site
    end

    initializer 'locomotive.i18n' do |app|
      app.config.i18n.available_locales = Locomotive.config.locales
    end

    initializer 'locomotive.notifications' do
      ActiveSupport::Notifications.subscribe('steam.serve.url_redirection') do |name, start, finish, id, payload|
        Locomotive::Site.inc_url_redirection_counter(payload[:site_id], payload[:url])
      end
    end

    initializer 'steam' do |app|
      require 'locomotive/steam_adaptor'
    end

  end
end
