module Admin
  class RobotsController < BaseController

    skip_before_filter :require_admin, :validate_site_membership, :set_locale

    before_filter :require_site

    respond_to :txt

    def show
      template = Liquid::Template.parse(current_site.robots_txt)
      render :text => template.render('request_host' => self.request.host.downcase)
    end

  end
end