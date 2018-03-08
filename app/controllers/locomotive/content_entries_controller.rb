module Locomotive
  class ContentEntriesController < BaseController

    account_required & within_site

    localized

    before_action :back_to_default_site_locale, only: [:new, :create]

    before_action :load_content_type
    before_action :load_content_entry, only: [:show, :show_in_form, :edit, :update, :destroy]
    before_action :store_location, only: [:edit, :update]

    respond_to :json, only: [:index, :sort]
    respond_to :csv,  only: [:export]

    helper 'Locomotive::CustomFields'

    def index
      authorize ContentEntry
      @content_entries = service.all(list_params)
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

    def show_in_form
      authorize @content_entry, :show?
      _content_type = current_site.content_types.where(slug: params[:parent_slug]).first
      @field        = _content_type.entries_custom_fields.find(params[:field_id])
      render partial: 'entry', locals: {
        slug:   params[:slug],
        item:   @content_entry,
        field:  @field
      }
    end

    def new
      @content_entry = @content_type.entries.build(params[:content_entry] ? content_entry_params : {})
      respond_with @content_entry
    end

    def create
      authorize ContentEntry
      @content_entry = service.create(content_entry_params)
      respond_with @content_entry, location: -> { location_after_persisting }
    end

    def edit
      authorize @content_entry
      respond_with @content_entry
    end

    def update
      authorize @content_entry
      service.update(@content_entry, content_entry_params)
      respond_with @content_entry, location: -> { location_after_persisting }
    end

    def sort
      authorize ContentEntry, :update?
      service.sort(params[:entries])
      respond_with @content_type, location: content_entries_path(current_site, @content_type.slug)
    end

    def destroy
      authorize @content_entry
      service.destroy(@content_entry)
      respond_with @content_entry, location: content_entries_path(current_site, @content_type.slug)
    end

    private

    def load_content_type
      @content_type ||= current_site.content_types.where(slug: params[:slug]).first!
    end

    def load_content_entry
      @content_entry = @content_type.entries.find(params[:id])
    end

    def service
      @service ||= Locomotive::ContentEntryService.new(load_content_type, current_locomotive_account)
    end

    def list_params
      if @content_type.order_manually?
        params.slice(:q, :where).merge(no_pagination: true)
      else
        params.slice(:page, :per_page, :q, :where)
      end
    end

    def content_entry_params
      params.require(:content_entry).permit(service.permitted_attributes)
    end

    def location_after_persisting
      default = edit_content_entry_path(current_site, @content_type.slug, @content_entry)

      if params[:_location].present?
        last_saved_location!(default)
      else
        default
      end
    end

  end
end
