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
        page.updated_by = account
        page.save
      end
    end

    # For all the pages of a site, use the title and template properties in
    # the default locale for all the new locales passed as the first argument.
    # Do not erase existing values in the new locales.
    #
    def localize(locales, previous_default_locale)
      default_locale = previous_default_locale || site.default_locale

      puts "---- #{default_locale.inspect} ----"

      site.pages.without_sorting.order_by(:depth.asc).each_by(50) do |page|
        puts page.attributes.inspect

        slug = page.attributes[:slug][default_locale]

        # if slug == 'index' || slug == '404'
          locales.each do |locale|
            next if locale == default_locale
            ::Mongoid::Fields::I18n.with_locale(locale) do
              page.slug ||= slug
            end
          end
        # end

        puts page.changes

        page.skip_update_children = true
        page.save if page.changed?
      end

      # second time: refresh fullpath
      # page.send(:build_fullpath)


      # site.pages.only(:title, :slug).each_by(50) do |page|
      #   puts page.attributes.inspect
      #   site.locales.each do |locale|
      #     next if page.attributes[:title][locale].present? && page.attributes[:slug][locale].present?
      #     puts "got job to do in #{locale}"

      #     if locale != site.default_locale
      #       puts "simple case: copy content from default_locale or previous_default_locale"
      #     end
      #   end
      # end

      # ::Mongoid::Fields::I18n.with_locale(site.default_locale) do
      #   site.pages.any_of({ title: nil }, { slug: nil }).each do |page|
      #     page.title ||= page.attributes[:title][previous_default_locale]
      #     page.slug ||= page.attributes[:slug][previous_default_locale]
      #     page.save
      #   end
      # end
      # default_locale = site.default_locale
      # # the pages must have a title/slug in the default locale
      # site.pages.where('$or' => [{ "title.#{default_locale}" => nil }, { "slug.#{default_locale}" => nil }]).each do |page|
      #   page.
      # end
    end

  end
end
