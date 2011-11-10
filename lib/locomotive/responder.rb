module Locomotive
  class Responder < ::ActionController::Responder

    include ::Responders::FlashResponder

    # by default flash_now messages if the resource has errors
    def set_flash_now?
      super || has_errors?
    end

    def to_json
      if get?
        display resource
      elsif has_errors?
        display resource.errors, :status => :unprocessable_entity
      elsif post?
        display resource, :status => :created, :location => api_location
      elsif put?
        display resource, :status => :ok, :location => api_location
      elsif has_empty_resource_definition?
        display empty_resource, :status => :ok
      else
        head :ok
      end
    end

    # def api_behavior(error)
    #   raise error unless resourceful?
    #
    #   # generate flash messages
    #   set_flash_message!
    #
    #   if get?
    #     display resource
    #   elsif has_errors?
    #     display({ :errors => resource.errors, :model => controller.send(:resource_instance_name), :alert => controller.flash[:alert] })
    #   elsif post?
    #     display resource, :status => :created, :location => resource_location
    #   else
    #     display({ :notice => controller.flash[:notice] })
    #   end
    #
    #   controller.flash.discard # reset flash messages !
    # end

  end
end