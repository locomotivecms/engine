module Locomotive
  module Api

    class SnippetsController < BaseController

      include Locomotive::Routing::SiteDispatcher

      def index
        @snippets = current_site.snippets.all
        respond_with(@snippets)
      end

      def create
        @snippet = current_site.snippets.create(params[:snippet])
        respond_with @snippet, :location => edit_snippet_url(@snippet._id)
      end

      def update
        @snippet = current_site.snippets.find(params[:id])
        @snippet.update_attributes(params[:snippet])
        respond_with @snippet, :location => edit_snippet_url(@snippet._id)
      end

    end

  end
end

