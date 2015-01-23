module Locomotive
  module Api
    class SnippetsController < Api::BaseController

      account_required & within_site

      before_filter :load_snippet,  only: [:show, :update, :destroy]
      before_filter :load_snippets, only: [:index]

      def index
        authorize Locomotive::Snippet
        @snippets = @snippets.order_by(:name.asc)
        respond_with @snippets
      end

      def show
        authorize @snippet
        respond_with @snippet
      end

      def create
        authorize Locomotive::Snippet
        @snippet = current_site.snippets.build
        @snippet.from_presenter(params[:snippet]).save
        respond_with @snippet, location: -> { main_app.locomotive_api_snippet_url(@snippet) }
      end

      def update
        authorize @snippet
        @snippet.from_presenter(params[:snippet]).save
        respond_with @snippet, location: main_app.locomotive_api_snippet_url(@snippet)
      end

      def destroy
        authorize Locomotive::Snippet
        @snippet.destroy
        respond_with @snippet, location: main_app.locomotive_api_snippets_url
      end

      private

      def load_snippet
        @snippet = current_site.snippets.find(params[:id])
      end

      def load_snippets
        @snippets = current_site.snippets
      end

    end
  end
end
