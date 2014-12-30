module Locomotive
  class SnippetsController < BaseController

    localized

    before_filter :back_to_default_site_locale, only: %w(new create)
    before_filter :load_snippet, only: [:show, :edit, :update, :destroy]

    respond_to    :json, only: [:show, :create, :update, :destroy]

    def new
      authorize Snippet
      @snippet = current_site.snippets.new
      respond_with @snippet
    end

    def show
      authorize @snippet
      respond_with @snippet
    end

    def create
      authorize Snippet
      @snippet = current_site.snippets.create(params[:snippet])
      respond_with @snippet, location: -> { edit_snippet_path(@snippet) }
    end

    def edit
      authorize @snippet
      respond_with @snippet
    end

    def update
      authorize @snippet
      @snippet.update_attributes(params[:snippet])
      respond_with @snippet, location: edit_snippet_path(@snippet)
    end

    def destroy
      authorize @snippet
      @snippet.destroy
      respond_with @snippet, location: theme_assets_path
    end

    private

    def load_snippet
      @snippet = current_site.snippets.find(params[:id])
    end

  end
end
