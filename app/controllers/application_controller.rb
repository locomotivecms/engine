class ApplicationController < ActionController::Base
  protect_from_forgery

  # rescue_from Exception, :with => :render_error

  private

  def render_error(exception)
    ActionDispatch::ShowExceptions.new(self).send(:log_error, exception) # TODO: find a better way to access log_error
    render :template => "/admin/errors/500", :layout => 'admin/box', :status => 500
  end
end
