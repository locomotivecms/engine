module Locomotive
  module Hosting
    module Heroku
      module FirstInstallation

        extend ActiveSupport::Concern

        included do

          class << self
            alias_method_chain :create_first_one, :heroku
          end

        end

        module ClassMethods

          def create_first_one_with_heroku(attributes)
            attributes[:subdomain] = ENV['APP_NAME']

            self.create_first_one_without_heroku(attributes)
          end

        end

      end
    end
  end
end