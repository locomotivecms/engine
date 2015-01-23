module Locomotive
  module Api
    class SitesController < Api::BaseController

      account_required

      before_filter :load_site, only: [:show, :update, :destroy]
      before_filter :load_sites, only: [:index]

      def index
        authorize Locomotive::Site
        respond_with @sites
      end

      def show
        authorize @site
        respond_with @site
      end

      def create
        authorize Locomotive::Site
        @site = Site.from_presenter(params[:site])
        @site.memberships.build account: self.current_locomotive_account, role: 'admin'
        @site.save
        respond_with @site, location: -> { main_app.locomotive_api_site_url(@site) }
      end

      def update
        authorize @site
        @site.from_presenter(params[:site]).save
        respond_with @site, location: main_app.locomotive_api_site_url(@site)
      end

      def destroy
        authorize @site
        @site.destroy
        respond_with @site, location: main_app.locomotive_api_sites_url
      end

      private

      def load_site
        @site = policy_scope(Locomotive::Site).find(params[:id])
      end

      def load_sites
        @sites = policy_scope(Locomotive::Site)
      end

      def current_membership
        membership = @site ? @site.membership_for(current_locomotive_account) : nil
        membership || Locomotive::Membership.new(account: current_locomotive_account)
      end

    end

  end
end
