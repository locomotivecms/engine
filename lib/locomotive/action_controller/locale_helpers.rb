module Locomotive
  module ActionController
    module LocaleHelpers

      extend ActiveSupport::Concern

      included do
        helper_method :current_content_locale, :localized?
      end

      def current_content_locale
        ::Mongoid::Fields::I18n.locale
      end

      def set_current_content_locale
        if params[:content_locale].present?
          session[:content_locale] = params[:content_locale]
        end

        unless current_site.locales.include?(session[:content_locale])
          session[:content_locale] = current_site.default_locale
        end

        ::Mongoid::Fields::I18n.locale = session[:content_locale]

        self.setup_i18n_fallbacks

        # logger.debug "*** content locale = #{session[:content_locale]} / #{::Mongoid::Fields::I18n.locale}"
      end

      def set_back_office_locale
        ::I18n.locale = current_locomotive_account.locale rescue Locomotive.config.default_locale
      end

      def back_to_default_site_locale
        session[:content_locale] = ::Mongoid::Fields::I18n.locale = current_site.default_locale
      end

      def setup_i18n_fallbacks
        (current_site.locales || []).each do |locale|
          ::Mongoid::Fields::I18n.fallbacks_for(locale, current_site.locale_fallbacks(locale))
        end
      end

      def localized?
        !!@locomotive_localized
      end

      module ClassMethods

        def localized(enable_it = true)
          before_filter do |c|
            c.instance_variable_set(:@locomotive_localized, enable_it)
          end
        end

      end

    end
  end
end