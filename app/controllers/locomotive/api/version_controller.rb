module Locomotive
  module Api
    class VersionController < ApplicationController

      skip_before_filter :require_account, :require_site, :set_current_thread_variables

      def show
        respond_to do |format|
          format.html { render text: Locomotive::VERSION }
          format.json { render json: { engine: Locomotive::VERSION } }
          format.xml  { render xml: { engine: Locomotive::VERSION } }
        end
      end

    end
  end
end
