module Locomotive
  class MembershipsController < BaseController

    account_required & within_site

    before_action :load_membership, only: [:edit, :update, :destroy]

    def new
      authorize Membership
      @membership = current_site.memberships.build
      respond_with @membership
    end

    def create
      authorize Membership
      if @membership = service.create(membership_params[:email])
        respond_with @membership, location: edit_current_site_path(current_site), flash: true
      else
        redirect_to new_account_path(email: membership_params[:email])
      end
    end

    def edit
      respond_with @membership
    end

    def update
      authorize @membership
      self.service.change_role(@membership, membership_params[:role])
      respond_with @membership, location: edit_current_site_path
    end

    def destroy
      authorize @membership
      @membership.destroy
      respond_with @membership, location: edit_current_site_path
    end

    protected

    def service
      policy = MembershipPolicy.new(pundit_user, @membership || Membership)
      @service ||= Locomotive::MembershipService.new(current_site, policy)
    end

    def load_membership
      @membership = current_site.memberships.find(params[:id])
    end

    def membership_params
      params.require(:membership).permit(*policy(@membership || Membership).permitted_attributes)
    end

  end
end
