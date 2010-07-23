require 'responders'

module Locomotive
  class AdminResponder < ::ActionController::Responder

    include ::Responders::FlashResponder

    def api_behavior(error)
      raise error unless resourceful?

      # generate flash messages
      set_flash_message!

      if get?
        display resource
      elsif has_errors?
        display({ :errors => resource.errors, :model => controller.send(:resource_instance_name), :alert => controller.flash[:alert] })
      elsif post?
        display resource, :status => :created, :location => resource_location
      else
        display({ :notice => controller.flash[:notice] })
      end

      controller.flash.discard # reset flash messages !
    end

  end
end
