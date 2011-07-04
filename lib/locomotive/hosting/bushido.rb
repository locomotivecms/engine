require 'locomotive/hosting/bushido/enabler'

module Locomotive
  module Hosting
    module Bushido

      def bushido?
        self.config.hosting == :bushido ||
        (self.config.hosting == :auto && ENV['APP_TLD'] == 'bushi.do')
      end

      def enable_bushido
        Locomotive.send(:include, Locomotive::Hosting::Bushido::Enabler)

        self.enable_bushido!
      end

    end
  end
end