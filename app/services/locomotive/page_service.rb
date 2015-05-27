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

  end
end
