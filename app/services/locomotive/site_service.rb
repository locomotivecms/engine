module Locomotive
  class SiteService < Struct.new(:account)

    include Morphine

    register :page_service do
      Locomotive::PageService.new(nil, account)
    end

    def list
      sorter = lambda do |site_a, site_b|
        site_a.name.downcase <=> site_b.name.downcase
      end

      account.sites.order_by(:name.asc).to_a.sort(&sorter)
    end

    def build_new
      Site.new(handle: unique_handle)
    end

    def create(attributes, raise_if_not_valid = false)
      if attributes[:handle].blank?
        attributes[:handle] = unique_handle
      end

      Site.new(attributes).tap do |site|
        site.memberships.build account: account, role: 'admin'

        raise_if_not_valid ? site.save! : site.save
      end
    end

    def create!(attributes)
      create(attributes, true)
    end

    def update(site, attributes)
      site.attributes = attributes

      new_locales = site.locales_changed? ? site.locales - site.locales_was : nil

      site.save.tap do |success|
        if success && new_locales.present?
          page_service.site = site
          page_service.localize(new_locales)
        end
      end
    end

    private

    def unique_handle
      Bazaar.heroku do |value|
        Site.where(handle: value).exists?
      end
    end

  end
end
