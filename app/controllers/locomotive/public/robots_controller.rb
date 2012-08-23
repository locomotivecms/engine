module Locomotive
  module Public
    class RobotsController < BaseController

      include Locomotive::Render

      respond_to :txt

      def show
        robots_template = ::Liquid::Template.parse(current_site.robots_txt)
        render :text => robots_template.render('request_host' => self.request.host.downcase)
      end

    end
  end
end