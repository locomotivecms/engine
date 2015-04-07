module Locomotive
  module API
    module Resources

      class VersionResource < Grape::API

        resource :version do

          desc 'Show current engine version'
          get do
            { engine: Locomotive::VERSION }
          end
        end

      end

    end
  end
end
