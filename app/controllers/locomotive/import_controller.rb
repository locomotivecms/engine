module Locomotive
  class ImportController < BaseController

    sections 'settings', 'site'

    skip_load_and_authorize_resource

    before_filter :authorize_import

    respond_to :json, :only => :show

    def show
      @import = Locomotive::Import::Model.current(current_site)
      respond_with @import
    end

    def new
      @import = Locomotive::Import::Model.new
      respond_with @import
    end

    def create
      @import = Locomotive::Import::Model.create(params[:import].merge(:site => current_site))
      respond_with @import, :location => Locomotive.config.delayed_job ? import_url : new_import_url
    end

    protected

    def authorize_import
      authorize! :import, Site
    end

  end
end