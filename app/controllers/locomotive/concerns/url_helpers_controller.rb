module Locomotive
  module Concerns
    module UrlHelpersController

      extend ActiveSupport::Concern

      included do
        helper_method :safe_dashboard_url, :current_site_public_url, :public_page_url
      end

      def safe_dashboard_url(site)
        dashboard_url({
          host:     site.full_subdomain,
          port:     request.port,
          protocol: request.ssl? ? 'https' : 'http'
        })
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
