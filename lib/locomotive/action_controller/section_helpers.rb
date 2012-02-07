module Locomotive
  module ActionController
    module SectionHelpers

      extend ActiveSupport::Concern

      def sections(key = nil)
        if !key.nil? && key.to_sym == :sub
          @locomotive_sections[:sub] || self.controller_name.dasherize
        else
          @locomotive_sections[:main]
        end
      end

      module ClassMethods

        def sections(main, sub = nil)
          before_filter do |c|
            sub = sub.call(c) if sub.respond_to?(:call)
            sections = { :main => main, :sub => sub }
            c.instance_variable_set(:@locomotive_sections, sections)
          end
        end

      end

    end
  end
end