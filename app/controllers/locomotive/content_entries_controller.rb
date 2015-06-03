module Locomotive
  class ContentEntriesController < BaseController

    sections 'contents'

    localized

    before_filter :back_to_default_site_locale, only: %w(new create)

    before_filter :get_content_type

    skip_load_and_authorize_resource

    before_filter :authorize_content

    respond_to :json, only: [:index, :show, :edit, :create, :update, :sort]

    respond_to :csv,  only: [:export]

    def index
      @content_entries = service.all(params.slice(:page, :per_page, :q, :where))
      respond_with @content_entries, html_view: true
    end

    def export
      @content_entries = @content_type.ordered_entries
      respond_with @content_entries, {
        filename:     @content_type.slug,
        col_sep:      ';',
        content_type: @content_type,
        host:         request.host_with_port
      }
    end

    def show
      @content_entry = @content_type.entries.find(params[:id])
      respond_with @content_entry
    end

    def new
      @content_entry = @content_type.entries.build
      respond_with @content_entry
    end

    def create
      @content_entry = @content_type.entries.create(params[:content_entry])
      respond_with @content_entry, location: edit_content_entry_path(@content_type.slug, @content_entry._id)
    end

    def edit
      @content_entry = @content_type.entries.find(params[:id])
      respond_with @content_entry
    end

    def update
      @content_entry = @content_type.entries.find(params[:id])
      @content_entry.update_attributes(params[:content_entry])
      respond_with @content_entry, location: edit_content_entry_path(@content_type.slug, @content_entry._id)
    end

    def sort
      @content_type.klass_with_custom_fields(:entries).sort_entries!(params[:entries], @content_type.sortable_column)
      respond_with @content_type
    end

    def destroy
      @content_entry = @content_type.entries.find(params[:id])
      @content_entry.destroy
      respond_with @content_entry, location: content_entries_path(@content_type.slug)
    end

    protected

    def get_content_type
      @content_type ||= current_site.content_types.by_id_or_slug(params[:slug]).first
    end

    def service
      @service ||= Locomotive::ContentEntryService.new(get_content_type)
    end

    def authorize_content
      authorize! params[:action].to_sym, ContentEntry
    end

  end
end
