module Locomotive
  module Api
    class ContentEntriesController < BaseController

      load_and_authorize_resource({
        class:                Locomotive::ContentEntry,
        through:              :get_content_type,
        through_association:  :entries,
        find_by:              :find_by_id_or_permalink
      })

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

    end
  end
end
