module Locomotive

  class PageService < Struct.new(:site, :account)

    include Locomotive::Concerns::ActivityService

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

        if page.save
          track_activity 'page.created', parameters: { title: page.title, _id: page._id }
        end
      end
    end

    def sort(page, children)
      page.sort_children!(children).tap do
        track_activity 'page.sorted', parameters: { title: page.title, _id: page._id }
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

        if page.save
          track_activity 'page.updated', parameters: { title: page.title, _id: page._id }
        end
      end
    end

    def destroy(page)
      page.destroy.tap do
        track_activity 'page.destroyed', parameters: { title: page.title }
      end
    end

    # For all the pages of a site, use the slug property from
    # the default locale for all the new locales passed as the first argument.
    # Do not erase existing values in the new locales.
    # This method is called when an user has changed the locales of a site.
    #
    def localize(locales, previous_default_locale)
      parent_fullpaths  = {}
      default_locale    = previous_default_locale || site.default_locale

      site.pages.without_sorting.order_by(:depth.asc).each_by(50) do |page|
        _localize(page, locales, default_locale, parent_fullpaths)

        page.skip_callbacks_on_update = true
        page.save if page.changed?
      end
    end

    private

    def _localize(page, locales, default_locale, parent_fullpaths)
      slug = page.slug_translations[default_locale]

      locales.each do |locale|
        next if locale == default_locale

        ::Mongoid::Fields::I18n.with_locale(locale) do
          page.slug         ||= slug
          page.fullpath     ||= page.depth > 1 ? parent_fullpaths[page.parent_id][locale] + '/' + slug : slug
          page.raw_template ||= page.raw_template_translations[default_locale]

          if page.depth == 0 && (slug == 'index' || slug == '404')
            page.title ||= ::I18n.t("attributes.defaults.pages.#{slug}.title", locale: locale)
          else
            page.title ||= "#{page.title_translations[default_locale]} [#{locale.upcase}]"
          end

          (parent_fullpaths[page._id] ||= {})[locale] = page.fullpath

          # finally, take care of the sections (inside the dropzone and the others)
          page.sections_content           = page.sections_content || page.sections_content_translations[default_locale] || {}
          page.sections_dropzone_content  = page.sections_dropzone_content || page.sections_dropzone_content_translations[default_locale] || []
        end
      end
    end

  end
end
