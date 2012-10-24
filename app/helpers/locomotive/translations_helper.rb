module Locomotive
  module TranslationsHelper
    def untranslated_locales(site, translation)
      list = site.locales.inject([]) do |memo,locale|
        translation.values[locale].present? ? memo :  memo << I18n.t("locomotive.locales.#{locale}")
      end
      
      if list.empty?
        ''
      else
        haml_tag :div, :class => 'more' do
          haml_tag :em, I18n.t('locomotive.translations.untranslated', :list => list.to_sentence), :class => 'untranslated'
        end
      end
    end
  end
end