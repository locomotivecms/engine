module Locomotive
  module Api
    class MembershipsController < Api::BaseController

      account_required & within_site

      before_filter :load_membership,  only: [:show, :update, :destroy]
      before_filter :load_memberships, only: [:index]

      def index
        authorize Locomotive::Membership
        respond_with @memberships
      end

      def show
        authorize @membership
        respond_with @membership
      end

      def create
        authorize Locomotive::Membership
        @membership = current_site.memberships.build
        @membership.from_presenter(params[:membership]).save
        respond_with @membership, location: -> { main_app.locomotive_api_membership_url(@membership) }
      end

      def update
        authorize @membership
        @membership.from_presenter(params[:membership]).save
        respond_with @membership, location: main_app.locomotive_api_membership_url(@membership)
      end

      def destroy
        authorize @membership
        @membership.destroy
        respond_with @membership, location: main_app.locomotive_api_memberships_url
      end

      private

      def load_membership
        @membership = current_site.memberships.find(params[:id])
      end

      def load_memberships
        @memberships = current_site.memberships
      end

    end

  end
end
