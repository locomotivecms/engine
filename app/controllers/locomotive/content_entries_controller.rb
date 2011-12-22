module Locomotive
  class ContentsController < BaseController

    sections 'contents'

    before_filter :set_content_type

    respond_to :json, :only => [:update, :sort]

    skip_load_and_authorize_resource

    before_filter :authorize_content

    def index
      @content_entries = @content_type.entries
      respond_with @content_entries
    end

    def new
      @content_entry = @content_type.entries.build
      respond_with @content
    end

    def create
      @content_entry = @content_type.entries.create(params[:content_entry])
      respond_with @content, :location => edit_content_entry_url(@content_type.slug, @content_entry._id)
    end

    def edit
      @content_entry = @content_type.entries.find(params[:id])
      respond_with @content
    end

    def update
      @content_entry = @content_type.entries.find(params[:id])
      @content_entry.update_attributes(params[:content_entry])
      respond_with @content, :location => edit_content_entry_url(@content_type.slug, @content_entry._id)
    end

    def sort
      # TODO
      # @content_type.sort_contents!(params[:children])
      # @page = current_site.pages.find(params[:id])
      # @page.sort_children!(params[:children])
      respond_with @content_type
    end

    def destroy
      @content_entry = @content_type.entries.find(params[:id])
      @content_entry.destroy
      respond_with @content, :location => pages_url
    end

    protected

    def set_content_type
      @content_type ||= current_site.content_types.where(:slug => params[:slug]).first
    end

    def authorize_content
      authorize! params[:action].to_sym, ContentEntry
    end

  end
end
