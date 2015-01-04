module Locomotive
  class ContentEntriesController < BaseController

    localized

    before_filter :back_to_default_site_locale, only: [:new, :create]

    before_filter :load_content_type
    before_filter :load_content_entry, only: [:show, :edit, :update, :destroy]
    before_filter :store_location, only: [:edit, :update]

    respond_to :json, only: [:index, :show, :edit, :create, :update, :sort, :destroy]
    respond_to :csv,  only: [:export]

    helper 'Locomotive::CustomFields'

    def index
      authorize ContentEntry
      @content_entries = service.all(params.slice(:page, :per_page, :q, :where))
      respond_with @content_entries
    end

    def export
      authorize ContentEntry, :index?
      @content_entries = @content_type.ordered_entries
      respond_with @content_entries, {
        filename:     @content_type.slug,
        col_sep:      ';',
        content_type: @content_type,
        host:         request.host_with_port
      }
    end

    def show
      authorize @content_entry
      @content_entry = @content_type.entries.find(params[:id])
      respond_with @content_entry
    end

    def new
      @content_entry = @content_type.entries.build
      respond_with @content_entry
    end

    def create
      authorize ContentEntry
      @content_entry = service.create(params[:content_entry])
      respond_with @content_entry, location: -> { location_after_persisting }
    end

    def edit
      authorize @content_entry
      respond_with @content_entry
    end

    def update
      authorize @content_entry
      service.update(@content_entry, params[:content_entry])
      respond_with @content_entry, location: -> { location_after_persisting }
    end

    def sort
      authorize ContentEntry, :update?
      @content_type.klass_with_custom_fields(:entries).sort_entries!(params[:entries], @content_type.sortable_column)
      respond_with @content_type
    end

    def destroy
      authorize @content_entry
      @content_entry.destroy
      respond_with @content_entry, location: content_entries_path(@content_type.slug)
    end

    private

    def load_content_type
      @content_type ||= current_site.content_types.where(slug: params[:slug]).first
    end

    def load_content_entry
      @content_entry = @content_type.entries.find(params[:id])
    end

    def service
      @service ||= Locomotive::ContentEntryService.new(load_content_type, current_locomotive_account)
    end

    def location_after_persisting
      default = edit_content_entry_path(@content_type.slug, @content_entry)

      if params[:_location].present?
        last_saved_location!(default)
      else
        default
      end
    end

  end
end
