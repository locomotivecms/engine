module Locomotive
  module Extensions
    module Site
      module Locales

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :locales, :type => 'RawArray', :default => []

          ## validations ##
          validate :can_not_remove_default_locale

          ## callbacks ##
          after_validation  :add_default_locale
          before_update     :verify_localized_default_pages_integrity

        end

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
        # @params [ Page ] page The page we want the localized fullpath
        # @params [ String ] locale The optional locale in place of the current one
        #
        # @returns [ String ] The localized fullpath according to the current locale
        #
        def localized_page_fullpath(page, locale = nil)
          return nil if page.fullpath_translations.blank?

          locale = (locale || I18n.locale).to_s
          fullpath = page.fullpath_translations[locale] || page.fullpath_translations[self.default_locale]

          locale == self.default_locale ? fullpath : File.join(locale, fullpath)
        end

        def locales=(array)
          array = [] if array.blank?; super(array)
        end

        def default_locale
          self.locales.first || Locomotive.config.site_locales.first
        end

        def default_locale_was
          self.locales_was.first || Locomotive.config.site_locales.first
        end

        def locale_fallbacks(locale)
          [locale.to_s] + (locales - [locale.to_s])
        end

        protected

        def add_default_locale
          self.locales = [Locomotive.config.site_locales.first] if self.locales.blank?
        end

        def can_not_remove_default_locale
          if self.persisted? && !self.locales.include?(self.default_locale_was)
            self.errors.add :locales, I18n.t(:default_locale_removed, :scope => [:errors, :messages, :site])
          end
        end

        def verify_localized_default_pages_integrity
          if self.persisted? && self.locales_changed?
            self.pages.where(:"slug.#{self.default_locale_was}".in => %w(index 404), :depth => 0).each do |page|
              modifications = { 'title' => {}, 'slug' => {}, 'fullpath' => {}, 'locales' => self.locales }

              self.locales.each do |locale|
                slug  = page.attributes['slug'][self.default_locale_was]
                title = page.attributes['title'][locale] || ::I18n.t("attributes.defaults.pages.#{slug}.title", :locale => locale)

                modifications['slug'][locale]     = slug
                modifications['fullpath'][locale] = slug
                modifications['title'][locale]    = title
              end

              page.collection.update({ :_id => page._id }, { '$set' => modifications })
            end
          end
        end

      end

    end
  end
end