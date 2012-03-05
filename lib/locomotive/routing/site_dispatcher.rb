module Locomotive
  module Routing
    module SiteDispatcher

      extend ActiveSupport::Concern

      included do
        if self.respond_to?(:before_filter)
          before_filter :fetch_site

          helper_method :current_site
        end
      end

      protected

      def fetch_site
        Locomotive.log "[fetch site] host = #{request.host} / #{request.env['HTTP_HOST']}"

        if Locomotive.config.multi_sites?
          @current_site ||= Site.match_domain(request.host).first
        else
          @current_site ||= Site.first
        end
      end

      def current_site
        @current_site || fetch_site
      end

      def require_site
        return true if current_site

        redirect_to installation_url and return false if Locomotive::Account.count == 0 || Locomotive::Site.count == 0

        render_no_site_error and return false
      end

      def render_no_site_error
        render :template => '/locomotive/errors/no_site', :layout => false, :status => :not_found
      end

      def validate_site_membership
        return true if current_site.present? && current_site.accounts.include?(current_locomotive_account)

        sign_out(current_locomotive_account)
        flash[:alert] = I18n.t(:no_membership, :scope => [:devise, :failure, :locomotive])
        redirect_to new_locomotive_account_session_url and return false
      end

    end

  end
end
