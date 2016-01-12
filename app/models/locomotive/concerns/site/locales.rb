module Locomotive
  module Concerns
    module Site
      module Locales

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :locales, type: ::RawArray, default: []
          field :prefix_default_locale, type: ::Boolean, default: false

          ## validations ##
          validate :can_not_remove_default_locale

          ## callbacks ##
          after_validation  :add_default_locale

        end

        def prefix_default_locale?
          self.prefix_default_locale
        end

        # Tell if the site serves other locales than the default one.
        #
        # @return [ Boolean ] True if the number of locales is greater than 1
        #
        def localized?
          self.locales.size > 1
        end

        # TODO: use the Steam service instead
        #
        # Returns the fullpath of a page in the context of the current locale (I18n.locale)
        # or the one passed in parameter. It also depends on the default site locale.
        #
        # Ex:
        #   For a site with its default site locale to 'en'
        #   # context 1: i18n.locale is 'en'
        #   contact_us.fullpath <= 'contact_us'
        #
        #   # context 2: i18n.locale is 'fr'
        #   contact_us.fullpath <= 'fr/nous_contacter'
        #
        # @param [ Page ] page The page we want the localized fullpath
        # @param [ String ] locale The optional locale in place of the current one
        #
        # @return [ String ] The localized fullpath according to the current locale
        #
        def localized_page_fullpath(page, locale = nil)
          return nil if page.fullpath_translations.blank?

          locale    = (locale || I18n.locale).to_s
          fullpath  = page.index? ? nil : (page.fullpath_translations[locale] || page.fullpath_translations[self.default_locale])
          locale_prefix = is_default_locale?(locale) && !prefix_default_locale ? nil : locale
          [locale_prefix, fullpath].compact.join '/'
        end

        def locales=(array)
          array.reject!(&:blank?)
          array = [] if array.blank?; super(array)
        end

        def default_locale
          self.locales.first || Locomotive.config.site_locales.first
        end

        def is_default_locale?(locale)
          locale.to_s == default_locale.to_s
        end

        def default_locale_was
          self.locales_was.try(:first) || Locomotive.config.site_locales.first
        end

        def locale_fallbacks(locale)
          [locale.to_s] + (locales - [locale.to_s])
        end

        # Iterate through all the locales of the site and for each of them
        # call yield with the related Mongoid::Fields::I18n locale context.
        # The first locale is the default one.
        #
        def each_locale(include_default_locale = true, &block)
          current_locale = ::Mongoid::Fields::I18n.locale
          _locales = include_default_locale ? self.locales : (self.locales - [self.default_locale])

          _locales.each do |locale|
            ::Mongoid::Fields::I18n.with_locale(locale) do
              yield locale, current_locale.to_s == locale.to_s
            end
          end
        end

        # Call yield within the Mongoid::Fields::I18 context of the default locale.
        #
        def with_default_locale(&block)
          ::Mongoid::Fields::I18n.with_locale(self.default_locale) do
            yield
          end
        end

        protected

        def add_default_locale
          self.locales = [Locomotive.config.site_locales.first] if self.locales.blank?
        end

        def can_not_remove_default_locale
          if self.persisted? && !self.locales.include?(self.default_locale_was)
            self.errors.add :locales, I18n.t(:default_locale_removed, scope: [:errors, :messages, :site])
          end
        end

      end

    end
  end
end
