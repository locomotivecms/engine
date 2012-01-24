module Locomotive
  module Api
    class ContentEntriesController < BaseController

      before_filter :set_content_type

      def index
        @content_entries = @content_type.list_or_group_entries
        respond_with @content_entries
      end

      def create
        @content_entry = @content_type.entries.create(params[:content_entry])
        respond_with @content_entry, :location => edit_locomotive_api_content_entry_url(@content_type.slug, @content_entry._id)
      end

      def update
        @content_entry = @content_type.entries.find(params[:id])
        @content_entry.update_attributes(params[:content_entry])
        respond_with @content_entry, :location => edit_locomotive_api_content_entry_url(@content_type.slug, @content_entry._id)
      end

      def destroy
        @content_entry = @content_type.entries.find(params[:id])
        @content_entry.destroy
        respond_with @content_entry, :location => locomotive_api_content_entries_url(@content_type.slug)
      end

      protected

      def set_content_type
        @content_type ||= current_site.content_types.where(:slug => params[:slug]).first
      end

    end
  end
end