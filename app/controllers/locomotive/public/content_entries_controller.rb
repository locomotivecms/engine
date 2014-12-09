module Locomotive
  module Public
    class ContentEntriesController < Public::BaseController

      include Locomotive::Render

      before_filter :set_locale

      before_filter :set_content_type

      before_filter :sanitize_entry_params, only: :create

      self.responder = Locomotive::ActionController::PublicResponder

      respond_to :html, :json

      def create
        @entry = @content_type.entries.safe_create(params[:entry] || params[:content])
        respond_with @entry
      end

      protected

      def set_locale
        ::I18n.locale = request.env['locomotive.locale'] || params[:locale] || current_site.default_locale
        ::Mongoid::Fields::I18n.locale = ::I18n.locale
      end

      def set_content_type
        @content_type = current_site.content_types.where(slug: params[:content_type_slug] || params[:slug]).first

        # check if ability to receive public submissions
        unless @content_type.public_submission_enabled?
          respond_to do |format|
            format.json { render json: { error: 'Public submissions not accepted' }, status: :forbidden }
            format.html { render text: 'Public submissions not accepted', status: :forbidden }
          end
          return false
        end
      end

      def sanitize_entry_params
        entry_params = params[:entry] || params[:content] || {}
        entry_params.each do |key, value|
          next unless value.is_a?(String)
          entry_params[key] = Sanitize.clean(value, Sanitize::Config::BASIC)
        end
      end

      # only verify csrf protection if it has been enable in the Locomotive config file
      def handle_unverified_request
        if Locomotive.config.csrf_protection
          reset_session
          redirect_to '/', status: 302
        end
      end

    end
  end
end