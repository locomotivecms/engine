module Locomotive
  module ActionController
    module LocaleHelpers

      extend ActiveSupport::Concern

      included do
        helper_method :current_content_locale
      end

      module InstanceMethods

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
          (current_site.locales || []).each do |locale|
            ::Mongoid::Fields::I18n.fallbacks_for(locale, current_site.locale_fallbacks(locale))
          end

          logger.debug "*** content locale = #{session[:content_locale]} / #{::Mongoid::Fields::I18n.locale}"
        end

        def set_back_office_locale
          ::I18n.locale = current_locomotive_account.locale rescue Locomotive.config.default_locale
        end

      end

    end
  end
end