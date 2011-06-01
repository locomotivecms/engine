module Locomotive
  module Hosting
    module Bushido
      module Devise

        extend ActiveSupport::Concern

        included do
          alias_method_chain :require_admin, :bushido
        end

        module InstanceMethods

          def require_admin_with_bushido
            if ::Locomotive.bushido_app_claimed?
              require_admin_without_bushido
            else
              # open back-office for everybody as long as the application is not claimed
              sign_in(Account.order_by(:created_at).first)
            end
          end

        end

      end
    end
  end
end