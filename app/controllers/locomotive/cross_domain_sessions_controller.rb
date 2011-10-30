module Locomotive
  class CrossDomainSessionsController < BaseController

    layout '/locomotive/layouts/box'

    skip_before_filter :verify_authenticity_token

    skip_before_filter :validate_site_membership

    before_filter :require_account, :only => :new

    skip_load_and_authorize_resource

    def new
      if site = current_account.sites.detect { |s| s._id.to_s == params[:target_id] }
        if Rails.env == 'development'
          @target = site.full_subdomain
        else
          @target = site.domains_without_subdomain.first || site.full_subdomain
        end

        current_account.reset_switch_site_token!
      else
        redirect_to admin_pages_path
      end
    end

    def create
      if account = Account.find_using_switch_site_token(params[:token])
        account.reset_switch_site_token!
        sign_in(account)
        redirect_to admin_pages_path
      else
        redirect_to new_admin_session_path, :alert => t('fash.locomotive.cross_domain_sessions.create.alert')
      end
    end

  end
end
