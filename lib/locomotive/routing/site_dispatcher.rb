module Locomotive
  module Routing
    module SiteDispatcher

      extend ActiveSupport::Concern

      included do
        if self.respond_to?(:before_filter)
          before_filter :fetch_site

          helper_method :current_site
          helper_method :current_membership
        end
      end

      protected

      def fetch_site
        @current_site ||= begin
          Locomotive.log "[fetch site] host = #{request.host} / #{request.env['HTTP_HOST']}"
          if Locomotive.config.multi_sites?
            Locomotive::Site.match_domain(request.host).first
          else
            Locomotive::Site.first
          end
        end
      end

      def current_site
        @current_site || fetch_site
      end

      def current_resource
        self.class.name.demodulize.underscore.gsub('_controller','').to_sym
      rescue
        :no_current_resource
      end

      def require_site
        return true if current_site

        if Locomotive::Account.count == 0 || Locomotive::Site.count == 0
          redirect_to installation_url
        else
          render_no_site_error
        end

        false # halt chain
      end

      def render_no_site_error
        respond_to do |format|
          format.html do
            render template: '/locomotive/errors/no_site', layout: false, status: :not_found
          end
          format.json do
            render json: { error: 'No site found' }, status: :not_found
          end
        end
      end

      def current_membership
        return @current_membership if @current_membership

        if current_site.present? && current_locomotive_account.present?
          @current_membership = current_site.membership_for(current_locomotive_account)
        else
          nil
        end
      end

      def validate_site_membership
        return true if current_membership

        sign_out(current_locomotive_account)
        flash[:alert] = I18n.t(:no_membership, scope: [:devise, :failure, :locomotive_account])
        redirect_to new_locomotive_account_session_url and return false
      end

    end

  end
end
