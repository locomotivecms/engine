module Locomotive
  module Liquid
    module Filters
      module Translate

        # Return the translation described by a key.
        #
        # @param [ String ] key The key of the translation.
        # @param [ String ] locale By default, it uses the value returned by I18n.locale
        # @param [ String ] scope If specified, instead of looking in the translations, it will use I18n instead.
        #
        # @return [ String ] the translated text
        #
        def translate(input, locale = nil, scope = nil)
          locale ||= I18n.locale.to_s

          if scope.blank?
            translation = Locomotive::Translation.where(key: input).first
            if translation.values[locale].present?
              translation.values[locale]
            else
              translation.values[I18n.default_locale.to_s]
            end
          else
            I18n.t(input, scope: scope.split('.'), locale: locale)
          end
        end

      end

      ::Liquid::Template.register_filter(Translate)
    end
  end
end
