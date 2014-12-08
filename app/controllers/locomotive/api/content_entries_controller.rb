module Locomotive
  module Api
    class ContentEntriesController < BaseController

      before_filter :load_content_type
      before_filter :load_content_entry,   only: [:show, :update, :destroy]
      before_filter :load_content_entries, only: [:index]

      def index
        authorize Locomotive::ContentEntry
        @content_entries = @content_entries.order_by([@content_type.order_by_definition])
        respond_with @content_entries
      end

      def show
        authorize @content_entry
        respond_with @content_entry, status: @content_entry ? :ok : :not_found
      end

      def create
        authorize Locomotive::ContentEntry
        @content_entry = @content_type.entries.build
        @content_entry.from_presenter(content_entry_params).save
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      def update
        authorize @content_entry
        @content_entry.from_presenter(content_entry_params).save
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      def destroy
        authorize @content_entry
        @content_entry.destroy
        respond_with @content_entry, location: main_app.locomotive_api_content_entries_url(@content_type.slug)
      end

      private

      def load_content_type
        @content_type = current_site.content_types.where(slug: params[:slug]).first
      end

      def load_content_entry
        @content_entry = @content_type.entries.find_by_id_or_permalink(params[:id])
      end

      def load_content_entries
        @content_entries = @content_type.entries
      end

      def content_entry_params
        params[:content_entry] || params[:entry]
      end

    end
  end
end
