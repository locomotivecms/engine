module Locomotive
  class InstallGenerator < Rails::Generators::Base

    source_root File.expand_path('../../../../../', __FILE__)

    class_option :heroku, type: :boolean, default: false, description: 'if the Engine is supposed to run on Heroku'

    def copy_initializers
      @source_paths = nil # reset it for the find_in_source_paths method

      Locomotive::InstallGenerator.source_root(File.expand_path('../templates', __FILE__))

      template 'locomotive.rb', 'config/initializers/locomotive.rb'

      template 'dragonfly.rb', 'config/initializers/dragonfly.rb'
    end

    def install_aws
      if options.heroku? || yes?('Do you want to store your assets on Amazon S3?')
        template 'carrierwave_aws.rb', 'config/initializers/carrierwave.rb'
        gem 'carrierwave-aws'
        gem 'rack-cors', require: 'rack/cors'
        inject_into_file 'Gemfile', after: "# the framework and any gems in your application.\n" do <<-RUBY

    config.assets.initialize_on_precompile = false

    config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
      allow do
        origins '*'
        resource '/assets/*', headers: :any, methods: :any
      end
    end

        RUBY
        end
      else
        template 'carrierwave.rb', 'config/initializers/carrierwave.rb'
      end
    end

    def insert_engine_routes
      route %(
  # Locomotive Back-office
  mount Locomotive::Engine => '/locomotive', as: 'locomotive' # you can change the value of the path, by default set to "/locomotive"

  # Locomotive API
  mount Locomotive::API.to_app => '/locomotive(/:site_handle)/api'

  # Render site
  mount Locomotive::Steam.to_app => '/', anchor: false)
    end

    def enable_heroku
      if options.heroku?
        inject_into_file 'Gemfile', after: "source 'https://rubygems.org'\n" do <<-'RUBY'

if ENV['HEROKU_APP_NAME']
  ruby '2.6.2'
end
        RUBY
        end

        template 'heroku.rb', 'config/initializers/heroku.rb'
        template 'mongoid_heroku.yml', 'config/mongoid.yml', force: true

        inject_into_file 'config/environments/production.rb', after: "  # config.action_mailer.raise_delivery_errors = false\n" do <<-'RUBY'
  config.action_mailer.raise_delivery_errors  = true
  config.action_mailer.delivery_method        = :smtp
  config.action_mailer.smtp_settings          = {
    :address        => 'smtp.sendgrid.net',
    :port           => 25,
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => ENV['SENDGRID_DOMAIN']
}
        RUBY
        end

        gem 'platform-api', '~> 2.2.0'
      end
    end

    def remove_index_html
      remove_file 'public/index.html'
    end

    def remove_robots_txt
      remove_file 'public/robots.txt'
    end

    def show_readme
      readme 'README'
    end

    private

    def generate_secret
      SecureRandom.hex(32)
    end

  end
end
