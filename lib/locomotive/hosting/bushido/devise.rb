module Locomotive
  module Hosting
    module Bushido
      module Devise

        extend ActiveSupport::Concern

        included do
          puts "Including special bushido admin methods"
          alias_method_chain :require_admin, :bushido
        end

        module InstanceMethods

          def require_admin_with_bushido
            puts "requiring admin with bushido.."
            puts "App claimed?"
            if ::Locomotive.bushido_app_claimed?
              
              require_admin_without_bushido
            else
              puts "not claimed! signing in #{Account.order(:created_at).first.inspect}"
              # open back-office for everybody as long as the application is not claimed
              sign_in(Account.order_by(:created_at).first)
            end
          end

        end

      end
    end
  end
end
