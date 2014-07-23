module Locomotive
  class SitesService

    def initialize(account)
      @account = account
    end

    def list
      sorter = lambda do |site_a, site_b|
        site_a.name.downcase <=> site_b.name.downcase
      end

      @account.sites.order_by(:name.asc).to_a.sort(&sorter)
    end

    def create(attributes)
      Site.new(attributes).tap do |site|
        site.memberships.build account: @account, role: 'admin'
        site.save
      end
    end

  end
end