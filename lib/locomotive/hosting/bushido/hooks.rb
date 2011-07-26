require 'bushido'

module Locomotive
  module Hosting
    module Bushido
      module Enabler

        module ClassMethods

          def subscribe_to_events
            ::Bushido::Data.listen('app.claimed') do |event|
              Locomotive.log "Saving #{Account.first.inspect} with incoming data #{event.inspect}"

              account = Account.first
              account.email = event['data'].try(:[], 'email')
              account.name = account.email.split('@').first
              account.save
            end
          end

        end
      end
    end
  end
end
