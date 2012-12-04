module Locomotive
  module Api
    class MembershipsController < BaseController

      # It's an embedded document, so we'll just load manually
      before_filter :load_membership,   :only => [:show, :update, :destroy]
      before_filter :load_memberships,  :only => [:index]

      authorize_resource :class => Locomotive::Membership

      def index
        respond_with(@memberships)
      end

      def show
        respond_with(@membership)
      end

      def create
        @membership = current_site.memberships.new
        @membership.from_presenter(params[:membership].merge(:role => 'author')) # force author by default
        @membership.save
        respond_with(@membership)
      end

      def update
        @membership.from_presenter(params[:membership])
        @membership.save
        respond_with(@membership)
      end

      def destroy
        @membership.destroy
        respond_with(@membership)
      end

      protected

      def load_membership
        @membership ||= load_memberships.find(params[:id])
      end

      def load_memberships
        @memberships ||= current_site.memberships
      end

    end

  end
end

