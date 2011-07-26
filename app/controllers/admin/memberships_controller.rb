module Admin
  class MembershipsController < BaseController

    sections 'settings'

    def create
      resource.role = 'author' # force author by default

      case resource.process!
      when :create_account
        redirect_to new_admin_account_url(:email => resource.email)
      when :save_it
        respond_with resource, :location => edit_admin_current_site_url
      when :error
        respond_with resource, :flash => true
      when :already_created
        respond_with resource, :alert => t('flash.admin.memberships.create.already_created'), :location => edit_admin_current_site_url
      end
    end

    def destroy
      destroy! { edit_admin_current_site_url }
    end

  end
end
