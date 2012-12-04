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

        renderer.render(parser.resources)
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

            self.sanitize_params(resource[:actions][action])
          end

          self.resources
        end

        protected

        def sanitize_params(action)
          return if action[:params].blank?

          action[:params].each do |name, type_or_all|
            next unless type_or_all.is_a?(String)

            action[:params][name] = { type: type_or_all, required: true }
          end
        end

      end # Processor

      class BootstrapRenderer

        # Create a single HTML page enhanced
        # by Twitter boostrap components.
        #
        def render(resources)
          source = File.read(self.path)
          Haml::Engine.new(source).render(Object.new, resources: resources)
        end

        protected

        def path
          File.join(File.dirname(__FILE__), 'api_documentation', 'bootstrap.html.haml')
        end

      end # BootstrapRenderer

    end
  end
end