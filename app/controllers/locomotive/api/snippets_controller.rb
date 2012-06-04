module Locomotive
  module Api
    class SnippetsController < BaseController

      load_and_authorize_resource :class => Locomotive::Snippet

      def index
        @snippets = current_site.snippets.order_by([[:name, :asc]])
        respond_with(@snippets)
      end

      def show
        @snippet = current_site.snippets.find(params[:id])
        respond_with @snippet
      end

      def create
        @snippet = current_site.snippets.create(params[:snippet])
        respond_with @snippet, :location => main_app.locomotive_api_snippets_url
      end

      def update
        @snippet = current_site.snippets.find(params[:id])
        @snippet.update_attributes(params[:snippet])
        respond_with @snippet, :location => main_app.locomotive_api_snippets_url
      end

      def destroy
        @snippet = current_site.snippets.find(params[:id])
        @snippet.destroy
        respond_with @snippet
      end

    end
  end
end

