module Locomotive
  module API
    module Helpers
      module AuthenticationHelper

        include Locomotive::Concerns::SiteDispatcherController

        def current_account
          @current_user ||= begin
            token = headers['X-Locomotive-Account-Token']
            email = headers['X-Locomotive-Account-Email']
            Account.where(email: email, authentication_token: token).first
          end
        end

        def authenticate_locomotive_account!
          error!('Unauthorized', 401) unless current_membership
          true
        end

        def current_site
          @current_site ||= request.env['locomotive.site']
        end

        def require_site!
          error!('Unknown site', 404) unless current_site
          true
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
  end
end
