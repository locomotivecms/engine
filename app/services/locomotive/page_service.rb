module Locomotive

  class PageService < Struct.new(:site, :account)

    # Create a page from the attributes passed in parameter.
    # It sets the created_by column with the current account.
    #
    # @param [ Hash ] attributes The attributes of new page.
    #
    # @return [ Object ] An instance of the page.
    #
    def create(attributes)
      site.pages.build(attributes).tap do |page|
        page.created_by = account if account
        page.save
      end
    end

    # Update a page from the attributes passed in parameter.
    # It sets the updated_by column with the current account.
    #
    # @param [ Object ] entry The page to update.
    # @param [ Hash ] attributes The attributes of new page.
    #
    # @return [ Object ] The instance of the page.
    #
    def update(page, attributes)
      page.tap do
        page.attributes = attributes
        page.updated_by = account if account
        page.save
      end
    end

    # For all the pages of a site, use the slug property from
    # the default locale for all the new locales passed as the first argument.
    # Do not erase existing values in the new locales.
    # This method is called when an user has changed the locales of a site.
    #
    # TODO:
    # x generic way to skip a callback in Mongoid. skip_callbacks accessor?
    # x build_fullpath from the previous loaded pages
    # 3. test if existing localized slug
    # 4. creating a new page: -> set the same slug in all the locales of the site + FULLPATH
    # x give a nice title of the index/404 page if blank
    # 6. use locales to check if the page has been translated or not

    # STEAM TODO:
    # - render a localized page even if there is no template (take the one in the default locale)
    def localize(locales, previous_default_locale)
      parent_fullpaths  = {}
      default_locale    = previous_default_locale || site.default_locale

      site.pages.without_sorting.order_by(:depth.asc).each_by(50) do |page|
        _localize(page, locales, default_locale, parent_fullpaths)

        page.skip_callbacks_on_update = true
        page.save if page.changed?
      end
    end

    def _localize(page, locales, default_locale, parent_fullpaths)
      slug = page.slug_translations[default_locale]

      locales.each do |locale|
        next if locale == default_locale

        ::Mongoid::Fields::I18n.with_locale(locale) do
          page.slug     ||= slug
          page.fullpath ||= page.depth > 1 ? parent_fullpaths[page.parent_id][locale] + '/' + slug : slug

          if page.depth == 0 && (slug == 'index' || slug == '404')
            page.title ||= ::I18n.t("attributes.defaults.pages.#{slug}.title", locale: locale)
          end

          (parent_fullpaths[page._id] ||= {})[locale] = page.fullpath
        end
      end
    end

  end
end
