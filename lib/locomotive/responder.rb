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
        Rails.logger.debug "--> ERRORS #{resource.errors.inspect}" # FIXME: debug purpose
        with_flash_message(:alert) do |message|
          display resource.errors, :status => :unprocessable_entity
        end
      elsif post?
        set_flash_message!
        display resource, :location => api_location
      elsif put?
        with_flash_message do |message|
          display resource, :status => :ok, :location => api_location
        end
      elsif has_empty_resource_definition?
        display empty_resource, :status => :ok
      else
        with_flash_message do
          head :ok
        end
      end
    end

    protected

    def with_flash_message(type = :notice)
      set_flash_message!
      message = controller.flash[type]

      controller.headers['X-Message']       = message
      controller.headers['X-Message-Type']  = type

      yield(message) if block_given?

      controller.flash.discard # reset flash messages !
    end

  end
end