module Locomotive
  class SitesController < BaseController

    sections 'settings'

    respond_to :json, :only => [:create, :destroy]

    def new
      @site = Site.new
      respond_with @site
    end

    def create
      @site = Site.new(params[:site])
      @site.memberships.build :account => self.current_locomotive_account, :role => 'admin'
      @site.save
      respond_with @site, :location => edit_my_account_url
    end

    def destroy
      @site = self.current_locomotive_account.sites.find(params[:id])

      if @site != current_site
        @site.destroy
      else
        @site.errors.add(:base, 'Can not destroy the site you are logging in now')
      end

      respond_with @site, :location => edit_my_account_url
    end

  end
end
