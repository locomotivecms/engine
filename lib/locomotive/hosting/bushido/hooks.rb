require 'bushido'

module Locomotive
  module Hosting
    module Bushido
      module Enabler

        module ClassMethods

          def subscribe_to_events
            ::Bushido::Data.listen('app.claimed') do |event|
              Locomotive.log "Saving #{Account.first.inspect} with incoming data #{event.inspect}"
              Locomotive.log "Devise username column: #{::Devise.cas_username_column}="
              Locomotive.log "Setting username to: #{event['data'].try(:[], 'ido_id')}"

              account = Account.first
              account.email = event['data'].try(:[], 'email')
              account.name = account.email.split('@').first
              account.send("#{::Devise.cas_username_column}=".to_sym, event['data'].try(:[], 'ido_id'))
              account.save
            end

            ::Bushido::Data.listen('user.added') do |event|
              Locomotive.log "Adding a new account with incoming data #{event.inspect}"
              Locomotive.log "Devise username column: #{::Devise.cas_username_column}="
              Locomotive.log "Setting username to: #{event['data'].try(:[], 'ido_id')}"

              account = Account.new(:email => event['data'].try(:[], 'email'))
              account.name = account.email.split('@').first
              account.send("#{::Devise.cas_username_column}=".to_sym, event['data'].try(:[], 'ido_id'))
              account.save

              Site.all.each do |site|
                site.memberships.create(:account => account) if account.errors.empty?
              end

            end

            ::Bushido::Data.listen('user.removed') do |event|
              Locomotive.log "Removing account based on incoming data #{event.inspect}"
              Locomotive.log "Devise username column: #{::Devise.cas_username_column}="
              Locomotive.log "Removing username: #{event['data'].try(:[], 'ido_id')}"

              ido_id = event['data'].try(:[], 'ido_id')

              ido_id and
                Account.exists?(:conditions => {::Devise.cas_username_column => ido_id}) and
                Account.where(::Devise.cas_username_column => ido_id).destroy
            end

          end

        end
      end
    end
  end
end
