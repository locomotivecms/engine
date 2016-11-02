module Locomotive
  class ErrorsController < ApplicationController

    layout '/locomotive/layouts/error'

    def error_404
      render '404', status: :not_found
    end

    def error_500
      render '500', status: :internal_server_error
    end

    def no_site
      respond_to do |format|
        format.html { render 'no_site', status: :not_found }
      end
    end

  end
end
