module Locomotive
  class RolesController < BaseController
    
    account_required & within_site

    before_action :load_role, only: [:edit, :update, :destroy]

    def new
      authorize Role
      @role = current_site.roles.build
      respond_with @role
    end

    def create
      authorize Role
      if @role = service.create(role_params)
        respond_with @role, location: edit_current_site_path(:anchor => "role"), flash: true
      else
        redirect_to new_role_path(current_site)
      end
    end

    def edit
      respond_with @role
    end

    def update
      authorize @role
      self.service.update(@role, role_params)
      respond_with @role, location: edit_current_site_path(:anchor => "role")
    end

    def destroy
      authorize @role
      @role.destroy
      respond_with @role, location: edit_current_site_path(:anchor => "role")
    end

    def new_model
      if params[:role_model].present?
        render partial: 'role_models', locals: { role_model: params[:role_model] }
      else
        head :unprocessable_entity
      end
    end

    protected

    def service
      @service ||= Locomotive::RoleService.new(current_site, current_locomotive_account)
    end

    def load_role
      @role = current_site.roles.find(params[:id])
    end

    def role_params
      params.require(:role).permit(*policy(@role || Role).permitted_attributes)
    end

  end
end