module Locomotive
  class SiteService < Struct.new(:account)

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

    private

    def unique_handle
      Bazaar.heroku do |value|
        Site.where(handle: value).exists?
      end
    end

  end
end
