module Locomotive
  module Public
    class ContentEntriesController < BaseController

      before_filter :set_content_type

      before_filter :sanitize_entry_params, :only => :create

      skip_load_and_authorize_resource

      self.responder = Locomotive::ActionController::PublicResponder # custom responder

      respond_to :html, :json

      def create
        @entry = @content_type.entries.create(params[:entry] || params[:content])
        flash[@content_type.slug.singularize] = @entry.to_presenter(:include_errors => true).as_json
        respond_with @entry, :location => self.callback_url
      end

      protected

      def set_content_type
        @content_type = current_site.content_types.where(:slug => params[:slug]).first

        # check if ability to receive public submissions
        unless @content_type.public_submission_enabled?
          respond_to do |format|
            format.json { render :json => { :error => 'Public submissions not accepted' }, :status => :forbidden }
            format.html { render :text => 'Public submissions not accepted', :status => :forbidden }
          end
          return false
        end
      end

      def callback_url
        (@entry.errors.empty? ? params[:success_callback] : params[:error_callback]) || main_app.root_path
      end

      def sanitize_entry_params
        entry_params = params[:entry] || params[:content] || {}
        entry_params.each do |key, value|
          next unless value.is_a?(String)
          entry_params[key] = Sanitize.clean(value, Sanitize::Config::BASIC)
        end
      end

      def handle_unverified_request
        if Locomotive.config.csrf_protection
          reset_session
          redirect_to '/', :status => 302
        end
      end

    end
  end
end
