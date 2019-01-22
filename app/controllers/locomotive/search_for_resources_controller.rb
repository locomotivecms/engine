module Locomotive
  class SearchForResourcesController < BaseController

    account_required & within_site

    respond_to :json, only: [:index]

    def index
      resources = service.find_resources(params[:type], params[:q], params[:scope])
      respond_with resources
    end

    private

    def service
      @service ||= EditorService.new(current_site)
    end

  end
end
