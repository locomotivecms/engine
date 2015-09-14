module Locomotive
  module TranslationsHelper

    def translation_completion_to_class(site, translation)
      (case translation.values.count { |v| v.present? }
      when 0                  then 'zero'
      when site.locales.size  then 'all'
      else 'partially'
      end) + '-done'
    end

  end
end
