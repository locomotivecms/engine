module Locomotive
  class ContentEntriesController < BaseController

    sections 'contents'

    localized

    before_filter :back_to_default_site_locale, only: %w(new create)

    before_filter :set_content_type

    skip_load_and_authorize_resource

    before_filter :authorize_content

    respond_to :json, only: [:index, :show, :edit, :create, :update, :sort]

    respond_to :csv,  only: [:export]

    def index
      options = { page: params[:page] || 1, per_page: Locomotive.config.ui[:per_page] }
      @content_entries = if params[:q]
        @content_type.ordered_entries(options.merge(q: params[:q]))
      else
        @content_type.list_or_group_entries(options)
      end
      respond_with @content_entries
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

    def set_content_type
      @content_type ||= current_site.content_types.where(slug: params[:slug]).first
    end

    def authorize_content
      authorize! params[:action].to_sym, ContentEntry
    end

  end
end