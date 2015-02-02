module Locomotive
  module APIAuthenticationHelpers
    include Concerns::SiteDispatcherController

    def current_account
      @current_user ||= begin
        token = headers['X-Locomotive-Account-Token']
        email = headers['X-Locomotive-Account-Email']
        Account.where(email: email, api_token: token).first
      end
    end

    def authenticate_locomotive_account!
      error!('401 Unauthorized', 401) unless current_membership
      true
    end

    def current_site
      @current_site ||= request.env['locomotive.site']
    end

    def current_membership
      return nil if current_account.nil?
      membership = current_site ? current_site.membership_for(current_account) : nil
      membership || Locomotive::Membership.new(account: current_account)
    end

    def pundit_user
      current_membership
    end

  end
end
