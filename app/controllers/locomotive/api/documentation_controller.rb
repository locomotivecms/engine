require 'locomotive/misc/api_documentation'

module Locomotive
  module Api
    class DocumentationController < ApplicationController

      before_filter :require_account

      def show
        render text: Locomotive::Misc::ApiDocumentation.generate
      end

      protected

      def require_account
        authenticate_locomotive_account!
      end

    end
  end
end