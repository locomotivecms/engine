module Locomotive
  class ContentsController < BaseController

    sections 'contents'

    before_filter :set_content_type

    respond_to :json, :only => [:update, :sort]

    skip_load_and_authorize_resource

    before_filter :authorize_content

    def index
      @contents = @content_type.contents
      respond_with @contents
    end

    def new
      @content = @content_type.contents.build
      respond_with @content
    end

    def create
      @content = @content_type.contents.create(params[:content])
      respond_with @content, :location => edit_content_url(@content_type.slug, @content._id)
    end

    def edit
      @content = @content_type.contents.find(params[:id])
      respond_with @content
    end

    def update
      @content = @content_type.contents.find(params[:id])
      @content.update_attributes(params[:content])
      respond_with @content, :location => edit_content_url(@content_type.slug, @content._id)
    end

    def sort
      # TODO
      # @content_type.sort_contents!(params[:children])
      # @page = current_site.pages.find(params[:id])
      # @page.sort_children!(params[:children])
      respond_with @content_type
    end

    def destroy
      @content = @content_type.contents.find(params[:id])
      @content.destroy
      respond_with @content, :location => pages_url
    end

    protected

    def set_content_type
      @content_type ||= current_site.content_types.where(:slug => params[:slug]).first
    end

    def authorize_content
      authorize! params[:action].to_sym, ContentInstance
    end

  end
end
