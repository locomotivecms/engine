module Locomotive
  module Liquid
    module Filters
      module Translate
        def translate(input, locale = nil)
          translation = Locomotive::Translation.where(key: input).first
          translation.values[locale] || translation.values[I18n.locale.to_s]
        end
      end
      
      ::Liquid::Template.register_filter(Translate)
    end
  end
end
