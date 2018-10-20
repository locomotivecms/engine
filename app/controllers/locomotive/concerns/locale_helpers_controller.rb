 module Locomotive
  module Concerns
    module LocaleHelpersController

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

        # set also the locale in the session steam uses for the preview
        # This is important because all the sites in preview mode belong to the same domain
        session["steam-locale-#{current_site.handle}"] = session[:content_locale]

        self.setup_i18n_fallbacks

        # logger.debug "*** content locale = #{session[:content_locale]} / #{::Mongoid::Fields::I18n.locale}"
      end

      def back_to_default_site_locale
        # we do force the content locale to the site default locale
        params.delete(:content_locale)

        session[:content_locale] = ::Mongoid::Fields::I18n.locale = current_site.default_locale
      end

      def setup_i18n_fallbacks
        ::Mongoid::Fields::I18n.clear_fallbacks
        (current_site.try(:locales) || []).each do |locale|
          ::Mongoid::Fields::I18n.fallbacks_for(locale, current_site.locale_fallbacks(locale))
        end
      end

      def localized?
        !!@locomotive_localized
      end

      module ClassMethods

        def localized(enable_it = true)
          before_action do |c|
            c.instance_variable_set(:@locomotive_localized, enable_it)
          end
        end

      end

    end
  end
end
