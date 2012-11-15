module Locomotive
  class ContentLocalePickerCell < Cell::Base

    helper do
      include ::Locomotive::BaseHelper
    end

    def show(args)
      site    = args[:site]
      @locale = args[:locale].to_s

      if site.locales.empty? || site.locales.size < 2
        ''
      else
        @locales = site.locales
        render
      end
    end

  end
end