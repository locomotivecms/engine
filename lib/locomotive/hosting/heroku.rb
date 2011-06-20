require 'locomotive/hosting/heroku/enabler'

module Locomotive
  module Hosting
    module Heroku

      def heroku?
        self.config.hosting == :heroku ||
        (self.config.hosting == :auto && ENV['HEROKU_SLUG'].present?)
      end

      def enable_heroku
        Locomotive.send(:include, Locomotive::Hosting::Heroku::Enabler)

        self.enable_heroku!
      end

    end
  end
end