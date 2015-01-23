module Locomotive
  module Api
    class VersionController < Api::BaseController

      def show
        respond_with({ engine: Locomotive::VERSION })
      end

    end
  end
end
