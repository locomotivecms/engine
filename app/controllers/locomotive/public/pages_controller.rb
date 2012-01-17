module Locomotive
  module Public
    class PagesController < ApplicationController

      include Locomotive::Routing::SiteDispatcher

      include Locomotive::Render

      before_filter :require_site

      before_filter :authenticate_locomotive_account!, :only => [:show_toolbar]

      before_filter :validate_site_membership, :only => [:show_toolbar]

      def show_toolbar
        render :layout => false
      end

      def show
        render_locomotive_page
      end

      def edit
        @editing = true
        render_locomotive_page
      end

    end
  end
end