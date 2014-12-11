module Locomotive
  class MembershipsController < BaseController

    def create
      @membership = current_site.memberships.build(params[:membership])
      @membership.role = 'author' # force author by default

      case @membership.process!
      when :create_account
        redirect_to new_account_path(email: @membership.email)
      when :save_it
        respond_with @membership, location: edit_current_site_path
      when :error
        respond_with @membership, flash: true
      when :already_created
        respond_with @membership, alert: t('flash.locomotive.memberships.create.already_created'), location: edit_current_site_path
      end
    end

    def edit
      @membership = current_site.memberships.find(params[:id])
      respond_with @membership
    end

    def update
      @membership = current_site.memberships.find(params[:id])
      self.service.change_role(@membership, params[:membership][:role])
      respond_with @membership, location: edit_current_site_path
    end

    def destroy
      @membership = current_site.memberships.find(params[:id])
      @membership.destroy
      respond_with @membership, location: edit_current_site_path
    end

    protected

    def service
      @service ||= Locomotive::MembershipsService.new(current_ability)
    end

  end
end