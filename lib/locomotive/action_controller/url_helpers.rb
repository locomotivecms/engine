module Locomotive
  module ActionController
    module UrlHelpers

      extend ActiveSupport::Concern

      included do
        helper_method :current_site_public_url, :switch_to_site_url, :public_page_url
      end

      def current_site_public_url
        request.protocol + request.host_with_port
      end

      def switch_to_site_url(site, options = {})
        options = { :fullpath => true, :protocol => true }.merge(options)

        url = "#{site.subdomain}.#{Locomotive.config.domain}"
        url += ":#{request.port}" if request.port != 80

        url = File.join(url, request.fullpath) if options[:fullpath]
        url = "http://#{url}" if options[:protocol]
        url
      end

      def public_page_url(page, options = {})
        Rails.logger.info "[public_page_url] =====> #{page.attributes.inspect} / #{page.fullpath.inspect}\n\n"
        if content = options.delete(:content)
          File.join(current_site_public_url, page.fullpath.gsub('content_type_template', ''), content._slug)
        else
          File.join(current_site_public_url, page.fullpath)
        end
      end

    end

  end
end