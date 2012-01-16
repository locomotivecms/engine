module Locomotive
  module Public
    class PagesController < ApplicationController

      include Locomotive::Routing::SiteDispatcher

      include Locomotive::Render

      before_filter :require_site

      before_filter :authenticate_locomotive_account!, :only => [:edit]

      before_filter :validate_site_membership, :only => [:edit]

      def show
        render_locomotive_page
      end

      def edit
        if params[:noiframe]
          @editing = true
          render_locomotive_page
        else
          render :layout => false
        end
      end

    end
  end
end