require 'responders'
require 'inherited_resources'
require 'inherited_resources/actions'
require 'inherited_resources/responder'

module InheritedResources
  # redirect to edit_resource_url instead of resource_url
  module Actions

    def create(options={}, &block)
      object = build_resource

      if create_resource(object)
        options[:location] ||= edit_resource_url rescue nil # change here
      end

      respond_with_dual_blocks(object, options, &block)
    end
    alias :create! :create

    # PUT /resources/1
    def update(options={}, &block)
      object = resource

      if update_resource(object, params[resource_instance_name])
        options[:location] ||= edit_resource_url rescue nil # change here
      end

      respond_with_dual_blocks(object, options, &block)
    end
    alias :update! :update

    # DELETE /resources/1
    def destroy(options={}, &block)
      object = resource
      options[:location] ||= collection_url rescue nil

      destroy_resource(object)

      options[:alert] = object.errors.full_messages.first # display the first error if present

      respond_with_dual_blocks(object, options, &block)
    end
    alias :destroy! :destroy

  end
end
