module Locomotive
  module Public
    class RobotsController < BaseController

      include Locomotive::Render

      respond_to :txt

      def show
        template = ::Liquid::Template.parse(current_site.robots_txt)
        render :text => template.render('request_host' => self.request.host.downcase)
      end

    end
  end
end