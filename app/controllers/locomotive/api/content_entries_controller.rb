module Locomotive
  module Api
    class ContentEntriesController < BaseController

      before_filter :load_content_entry,   only: [:show, :destroy]
      before_filter :load_content_entries, only: [:index]

      def index
        @content_entries = @content_entries.order_by([get_content_type.order_by_definition])
        respond_with @content_entries
      end

      def show
        respond_with @content_entry, status: @content_entry ? :ok : :not_found
      end

      def create
        @content_entry.from_presenter(params[:content_entry] || params[:entry])
        @content_entry.save
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      def update
        @content_entry.from_presenter(params[:content_entry] || params[:entry])
        @content_entry.save
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      def destroy
        @content_entry.destroy
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      protected

      def get_content_type
        @content_type ||= current_site.content_types.where(slug: params[:slug]).first
      end

      private

      def load_content_entry
        @content_entry = get_content_type.entries.find_by_id_or_permalink params[:id]
      end

      def load_content_entries
        @content_entries = get_content_type.entries
      end

    end
  end
end
