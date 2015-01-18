module Locomotive
  module Concerns
    module MembershipController

      extend ActiveSupport::Concern

      included do
        helper_method :current_membership
      end

      protected

      def current_membership
        return @current_membership if @current_membership

        if current_site.present? && current_locomotive_account.present?
          @current_membership = current_site.membership_for(current_locomotive_account)
        elsif current_locomotive_account.present?
          @current_membership = Locomotive::Membership.new(account: current_locomotive_account)
        else
          nil
        end
      end

      def validate_site_membership
        return true if current_membership.try(:site).present?

        sign_out(current_locomotive_account)
        flash[:alert] = I18n.t(:no_membership, scope: [:devise, :failure, :locomotive_account])
        redirect_to new_locomotive_account_session_url and return false
      end

    end
  end
end
