module Locomotive
  module Api
    class ContentEntriesController < BaseController

      before_filter :set_content_type

      def index
        @content_entries = @content_type.ordered_entries
        respond_with @content_entries
      end

      def show
        @content_entry = @content_type.entries.any_of({ :_id => params[:id] }, { :_slug => params[:id] }).first
        respond_with @content_entry, :status => @content_entry ? :ok : :not_found
      end

      def create
        # FIXME need to use "create" here. Things go wrong if we use "new" and
        # "update_attributes" with the presenter
        @content_entry_presenter = Locomotive::ContentEntryPresenter.create(@content_type, params[:content_entry])
        respond_with @content_entry_presenter, :location => main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      def update
        @content_entry = @content_type.entries.find(params[:id])
        @content_entry.update_attributes(params[:content_entry])
        respond_with @content_entry, :location => main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      def destroy
        @content_entry = @content_type.entries.find(params[:id])
        @content_entry.destroy
        respond_with @content_entry, :location => main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      protected

      def set_content_type
        @content_type ||= current_site.content_types.where(:slug => params[:slug]).first
      end

    end
  end
end
