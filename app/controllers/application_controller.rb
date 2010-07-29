class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from Exception, :with => :render_error

  protected

  def render_error
    render :template => "/admin/errors/500", :layout => 'admin/box', :status => 500
  end
end
