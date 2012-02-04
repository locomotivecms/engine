module Locomotive
  module Extensions
    module Site
      module Locales

        extend ActiveSupport::Concern

        included do

          ## fields ##
          field :locales, :type => 'RawArray', :default => []

          ## callbacks ##
          after_validation :add_default_locale
          # after_validation :add_missing_locales_for_all_pages

        end

        module InstanceMethods

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

          def locale_fallbacks(locale)
            [locale.to_s] + (locales - [locale.to_s])
          end

          protected

          def add_default_locale
            self.locales = [Locomotive.config.site_locales.first] if self.locales.blank?
          end

          #
          # def add_missing_locales_for_all_pages
          #   if self.locales_changed?
          #     list = self.pages.to_a
          #
          #     while !list.empty? do
          #       page = list.pop
          #       begin
          #         page.send(:set_slug_and_fullpath_for_all_locales, self.locales)
          #
          #         page.save
          #
          #       rescue TypeError => e
          #         list.insert(0, page)
          #       end
          #     end
          #   end
          # end

        end

      end
    end
  end
end