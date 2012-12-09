require 'haml'

module Locomotive
  module Misc

    # Class to generate the documentation about the LocomotiveCMS Rest API
    #
    module ApiDocumentation

      # Generate the documentation depending on the renderer
      # which is by default the BoostrapRenderer.
      #
      # @param [ Object ] renderer The instance of the renderer.
      #
      #
      def self.generate(renderer = nil)
        renderer ||= BootstrapRenderer.new

        raise 'You must provide a renderer' if renderer.nil?

        parser = Parser.new
        parser.parse

        renderer.render(parser.resources, self.embedded_resources)
      end

      # Return the list of embedded resources
      #
      # @return [ Array ] The list of hashes (keys: name, getters, setters)
      #
      def self.embedded_resources
        %w(editable_element editable_short_text editable_long_text editable_file editable_control content_field).map do |name|
          klass = "Locomotive::#{name.camelize}Presenter".constantize
          {
            name:     name,
            getters:  klass.getters_to_hash,
            setters:  klass.setters_to_hash,
          }
        end
      end

      class Parser

        attr_reader :resources

        def initialize
          @resources = []
        end

        # Take all the routes and build the set of RESTFUL resources
        #
        def parse
          routes = Rails.application.routes.routes.each do |route|
            next unless route.path.spec.to_s =~ %r{^/locomotive/api/}

            name        = route.defaults[:controller].split('/').last
            resource    = resources.find { |r| r[:name] == name }
            controller  = "#{route.defaults[:controller]}_controller".camelize.constantize
            action      = route.defaults[:action].to_sym
            verb        = route.verb.inspect.gsub("\/^", '').gsub("$\/", '')

            if resource.nil?
              resource = controller.description
              resource[:name] = name
              self.resources << resource
            end

            resource[:actions][action] ||= {}
            resource[:actions][action].merge!(path: route.path.spec.to_s, verb: verb)

            self.sanitize_attributes(resource[:actions][action])
          end

          self.resources
        end

        protected

        def sanitize_attributes(action)
          action[:params].each do |name, type_or_all|
            next unless type_or_all.is_a?(String)
            action[:params][name] = { type: type_or_all, required: true }
          end unless action[:params].blank?

          action[:response].each do |name, type_or_all|
            next unless type_or_all.is_a?(String)
            action[:response][name] = { type: type_or_all }
          end unless action[:response].blank?
        end

      end # Processor

      class BootstrapRenderer

        # Create a single HTML page enhanced
        # by Twitter boostrap components.
        #
        def render(resources, embedded_resources)
          source = File.read(self.path)
          engine = Haml::Engine.new(source)
          engine.render(Object.new, resources: resources, embedded_resources: embedded_resources)
        end

        protected

        def path
          File.join(File.dirname(__FILE__), 'api_documentation', 'bootstrap.html.haml')
        end

      end # BootstrapRenderer

    end
  end
end