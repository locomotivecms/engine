module Admin
  class SitesController < BaseController

    defaults :instance_name => 'site'

    sections 'settings'

    def create
      @site = Site.new(params[:site])
      @site.memberships.build :account => @current_admin, :admin => true

      create! { edit_admin_my_account_url }
    end

    def destroy
      @site = current_admin.sites.find(params[:id])

      if @site != current_site
        @site.destroy
      else
        @site.errors.add(:base, 'Can not destroy the site you are logging in now')
      end

      respond_with @site, :location => edit_admin_my_account_url
    end

    protected

    def begin_of_association_chain; nil; end # not related directly to current_site

  end
end
