module Locomotive
  module Api
    class SitesController < BaseController

      skip_before_filter :require_site, :set_locale, :set_current_thread_variables

      load_and_authorize_resource :class => Locomotive::Site

      # We make an exception for the index action, we don't use the ability
      # object, we just return the sites owned by the current account.
      skip_load_and_authorize_resource :only => :index

      def index
        @sites = self.current_locomotive_account.sites.all
        respond_with(@sites)
      end

      def show
        respond_with(@site)
      end

      def create
        @site.memberships.build :account => self.current_locomotive_account, :role => 'admin'
        @site.save
        respond_with(@site)
      end

      def update
        @site.update_attributes(params[:site])
        respond_with(@site)
      end

      def destroy
        @site.destroy
        respond_with(@site)
      end

    end

  end
end

