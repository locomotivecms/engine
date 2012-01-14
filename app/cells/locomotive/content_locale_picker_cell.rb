class Locomotive::ContentLocalePickerCell < Cell::Base

  def show(args)
    site    = args[:site]
    locale  = args[:locale].to_s

    logger.debug "site.locales = #{site.locales.inspect} / #{site.locales.size}"

    if site.locales.empty? || site.locales.size < 2
      ''
    else
      @locales = site.locales - [locale]
      render
    end
  end

end