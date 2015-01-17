module Locomotive
  module Concerns
    module UrlHelpersController

      extend ActiveSupport::Concern

      included do
        helper_method :public_page_url
      end

      def current_site_public_url
        # by convention, a public site is displayed in http not https.
        'http://' + request.host_with_port
      end

      def public_page_url(page, options = {})
        # Rails.logger.debug "[public_page_url] =====> #{page.attributes.inspect} / #{page.fullpath.inspect} / #{current_site_public_url}\n\n"

        locale    = options[:locale]
        fullpath  = current_site.localized_page_fullpath(page, locale)

        if content = options.delete(:content)
          fullpath = fullpath.gsub('content_type_template', content._slug)
        end

        File.join(current_site_public_url, fullpath)
      end

    end

  end
end
