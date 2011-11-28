module Locomotive
  class SnippetsController < BaseController

    sections 'settings', 'theme_assets'

    respond_to :json, :only => :update

    def new
      @snippet = current_site.snippets.new
      respond_with @snippet
    end

    def create
      @snippet = current_site.snippets.create(params[:snippet])
      respond_with @snippet, :location => edit_snippet_url(@snippet)
    end

    def edit
      @snippet = current_site.snippets.find(params[:id])
      respond_with @snippet
    end

    def update
      @snippet = current_site.snippets.find(params[:id])
      @snippet.update_attributes(params[:id])
      respond_with @snippet, :location => edit_snippet_url(@snippet)
    end

    def destroy
      @snippet = current_site.snippets.find(params[:id])
      @snippet.destroy
      respond_with @snippet, :location => theme_assets_url
    end

  end
end
