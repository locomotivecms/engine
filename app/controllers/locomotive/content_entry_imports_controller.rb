module Locomotive
  class ContentEntryImportsController < BaseController

    account_required & within_site

    before_action :only_if_import_enabled

    def show
      authorize @content_type, :import?
    end

    def new
      authorize @content_type, :import?
      @import = Locomotive::ContentEntryImport.new
    end

    def create
      authorize @content_type, :import?
      @import = Locomotive::ContentEntryImport.new(import_params)
      service.async_import(@import.file, @import.options) if @import.valid?
      respond_with @import, location: content_entry_import_path(current_site, @content_type.slug)
    end

    def destroy
      authorize @content_type, :import?
      message = t('flash.locomotive.content_entry_imports.destroy.notice')
      service.cancel(message)
      flash[:alert] = message
      redirect_to new_content_entry_import_path(current_site, @content_type.slug)
    end

    private    

    def only_if_import_enabled
      redirect_to content_entries_path(current_site, content_type.slug) unless content_type.import_enabled
    end

    def content_type
      @content_type ||= current_site.content_types.where(slug: params[:slug]).first!
    end

    def service
      @service ||= Locomotive::ContentEntryImportService.new(content_type)
    end

    def import_params
      params.require(:content_entry_import).permit(:file, :col_sep, :quote_char)
    end
  end
end
