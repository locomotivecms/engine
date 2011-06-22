require 'locomotive'

unless Locomotive.engine?

  require 'dragonfly'
  require 'uri'

  ## initialize Dragonfly ##

  app = Dragonfly[:images]
  app.configure_with(:rails)
  app.configure_with(:imagemagick)

  ## insert the middleware ##
  Rails.application.middleware.insert 0, 'Dragonfly::Middleware', :images

  ## configure it ##

  Dragonfly[:images].configure do |c|
    # Convert absolute location needs to be specified
    # to avoid issues with Phusion Passenger not using $PATH
    convert = `which convert`.strip.presence || "/usr/local/bin/convert"
    c.convert_command  = convert
    c.identify_command = convert

    c.allow_fetch_url  = true
    c.allow_fetch_file = true
  end

  ## disable rack-cache for heroku and enable it for the other platforms ##

  unless Locomotive.heroku? # has already a reverse-proxy caching system with Varnish
    begin
      require 'rack/cache'
      Rails.application.middleware.insert_before 'Dragonfly::Middleware', 'Rack::Cache', {
        :verbose     => false,
        :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
        :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
      }
    rescue LoadError => e
      app.log.warn("Warning: couldn't find rack-cache for caching dragonfly content")
    end
  end
end



