module Admin
  class ApiContentsController < ActionController::Base

    include Locomotive::Routing::SiteDispatcher

    before_filter :require_site

    before_filter :set_content_type

    def create
      @content = @content_type.contents.build(params[:content])

      respond_to do |format|
        if @content.save
          format.json { render :json => { :content => @content } }
        else
          format.json { render :json => { :content => @content, :errors => @content.errors } }
        end
      end
    end

    protected

    def set_content_type
      @content_type = current_site.content_types.where(:slug => params[:slug]).first
      render :json => { :error => 'Api not enabled'} and return false unless @content_type.api_enabled
    end

  end
end
