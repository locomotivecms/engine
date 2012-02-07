module Locomotive
  module Api
    class SnippetsController < BaseController

      def index
        @snippets = current_site.snippets.all
        respond_with(@snippets)
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

    end
  end
end

