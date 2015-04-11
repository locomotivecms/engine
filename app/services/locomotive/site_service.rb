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

    def create(attributes)
      if attributes[:handle].blank?
        attributes[:handle] = unique_handle
      end

      Site.new(attributes).tap do |site|
        site.memberships.build account: account, role: 'admin'

        site.save
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
