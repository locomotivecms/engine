module Admin
  class ApiContentsController < ActionController::Base

    include Locomotive::Routing::SiteDispatcher

    before_filter :require_site

    before_filter :set_content_type

    before_filter :block_content_type_with_disabled_api

    before_filter :sanitize_content_params, :only => :create

    def create
      @content = @content_type.contents.build(params[:content])

      respond_to do |format|
        if @content.save
          format.json { render :json => { :content => @content } }
          format.html do
            flash[@content_type.slug.singularize] = @content.aliased_attributes
            redirect_to params[:success_callback]
          end
        else
          format.json { render :json => { :content => @content, :errors => @content.errors } }
          format.html do
            flash[@content_type.slug.singularize] = @content.aliased_attributes
            flash['errors'] = @content.errors_to_hash
            redirect_to params[:error_callback]
          end
        end
      end
    end

    protected

    def set_content_type
      @content_type = current_site.content_types.where(:slug => params[:slug]).first
    end

    def block_content_type_with_disabled_api
      unless @content_type.api_enabled?
        respond_to do |format|
          format.json { render :json => { :error => 'Api not enabled' }, :status => :forbidden  }
          format.html { render :text => 'Api not enabled', :status => :forbidden }
        end
        return false
      end
    end

    def sanitize_content_params
      (params[:content] || {}).each do |key, value|
        next unless value.is_a?(String)
        params[:content][key] = Sanitize.clean(value, Sanitize::Config::BASIC)
      end
    end

  end
end
