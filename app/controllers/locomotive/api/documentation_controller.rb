require 'locomotive/misc/api_documentation'

module Locomotive
  module Api

    class DocumentationController < ApplicationController

      def show
        render text: Locomotive::Misc::ApiDocumentation.generate
      end

    end

  end
end