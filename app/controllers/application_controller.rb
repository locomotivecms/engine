class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  # rescue_from Exception, :with => :render_error
  #
  # def render_error
  #   render :template => "/admin/errors/500", :layout => '/admin/layouts/box', :status => 500
  # end
end
