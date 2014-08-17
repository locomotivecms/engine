module Locomotive
  class LocalesInput < ArrayInput

    def input_html
      template.select_tag 'locale', collection: template.options_for_locale, include_blank: false
    end

  end
end