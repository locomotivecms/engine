module Admin
  class ExportController < BaseController

    skip_load_and_authorize_resource

    before_filter :authorize_export

    def new
      zipfile = ::Locomotive::Export.run!(current_site, current_site.name.parameterize)
      send_file zipfile, :type => 'application/zip', :disposition => 'attachment'
    end

    protected

    def authorize_export
      authorize! :export, Site
    end

  end
end