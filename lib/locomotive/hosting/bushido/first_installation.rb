module Locomotive
  module Hosting
    module Bushido
      module FirstInstallation

        extend ActiveSupport::Concern

        included do
          class << self
            alias_method_chain :create_first_one, :bushido
          end
        end

        module ClassMethods

          def create_first_one_with_bushido(attributes)
            unless Locomotive.config.multi_sites?
              attributes[:subdomain] = ENV['BUSHIDO_APP']
            end

            self.create_first_one_without_bushido(attributes)
          end

        end

      end
    end
  end
end