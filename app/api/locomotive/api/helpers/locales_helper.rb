module Locomotive
  module API
    module Helpers
      module LocalesHelper

        include Locomotive::Concerns::SiteDispatcherController

        def back_to_default_site_locale
          ::Mongoid::Fields::I18n.locale = current_site.default_locale
        end

      end
    end
  end
end
