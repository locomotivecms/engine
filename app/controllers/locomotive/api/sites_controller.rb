module Locomotive
  module Api
    class SitesController < BaseController

      load_and_authorize_resource :class => Locomotive::Site

      # FIXME: the auto-loaded site won't pass authorization for show, update, or destroy
      skip_load_and_authorize_resource :only => [ :show, :update, :destroy ]

      def index
        @sites = Locomotive::Site.all
        respond_with(@sites)
      end

      def show
        @site = Locomotive::Site.find(params[:id])
        authorize! :show, @site
        respond_with(@site)
      end

      def create
        @site = Locomotive::Site.create(params[:site])
        respond_with(@site)
      end

      def update
        @site = Locomotive::Site.find(params[:id])
        authorize! :update, @site
        @site.update_attributes(params[:site])
        respond_with @site
      end

      def destroy
        @site = Locomotive::Site.find(params[:id])
        authorize! :destroy, @site
        @site.destroy
        respond_with @site
      end

    end

  end
end

