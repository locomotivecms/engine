module Admin
  class RobotsController < ActionController::Base

    include Locomotive::Routing::SiteDispatcher

    include Locomotive::Render

    before_filter :require_site

    respond_to :txt

    def show
      template = Liquid::Template.parse(current_site.robots_txt)
      render :text => template.render('request_host' => self.request.host.downcase)
    end

  end
end