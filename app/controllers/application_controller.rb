class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  unless Rails.env.development? || Rails.env.test?
    rescue_from Exception, :with => :render_error

    def render_error
      render :template => "/admin/errors/500", :layout => 'admin/box', :status => 500
    end
  end
end
