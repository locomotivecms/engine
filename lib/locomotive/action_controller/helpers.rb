module Locomotive
  module ActionController
    module Helpers

      extend ActiveSupport::Concern

      included do
        helper_method :current_site_public_url, :switch_to_site_url, :public_page_url, :current_content_locale
      end

      module InstanceMethods

        # ___ locales ___

        def current_content_locale
          ::Mongoid::Fields::I18n.locale
        end

        def set_current_content_locale
          # I18n.default_site_locale = current_site.default_locale

          if params[:content_locale].present?
            session[:content_locale] = params[:content_locale]
          end

          unless current_site.locales.include?(session[:content_locale])
            session[:content_locale] = current_site.default_locale
          end

          ::Mongoid::Fields::I18n.locale = session[:content_locale]
          (current_site.locales || []).each do |locale|
            ::Mongoid::Fields::I18n.fallbacks_for(locale, current_site.locale_fallbacks(locale))
          end

          logger.debug "*** content locale = #{session[:content_locale]} / #{::Mongoid::Fields::I18n.locale}"
        end

        def set_back_office_locale
          ::I18n.locale = current_locomotive_account.locale rescue Locomotive.config.default_locale
        end

        def sections(key = nil)
          if !key.nil? && key.to_sym == :sub
            @locomotive_sections[:sub] || self.controller_name.dasherize
          else
            @locomotive_sections[:main]
          end
        end

        # ___ site/page urls builder ___

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
          if content = options.delete(:content)
            File.join(current_site_public_url, page.fullpath.gsub('content_type_template', ''), content._slug)
          else
            File.join(current_site_public_url, page.fullpath)
          end
        end

      end

      module ClassMethods

        def sections(main, sub = nil)
          before_filter do |c|
            sub = sub.call(c) if sub.respond_to?(:call)
            sections = { :main => main, :sub => sub }
            c.instance_variable_set(:@locomotive_sections, sections)
          end
        end

      end

    end
  end
end