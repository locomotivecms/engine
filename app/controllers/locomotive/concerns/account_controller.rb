module Locomotive
  module Concerns

    # When called, the account_required method enhances the controller by:
    #
    #   - checking if someone is authentified or not.
    #   - setting the right locale for the UI based on the authenticated account.
    #
    module AccountController

      extend ActiveSupport::Concern

      private

      def require_account
        authenticate_locomotive_account!
      end

      def set_back_office_locale
        ::I18n.locale = current_locomotive_account.locale rescue Locomotive.config.default_locale
      end

      public

      module ClassMethods

        def account_required
          class_eval do
            before_filter :require_account

            before_filter :set_back_office_locale
          end
        end

      end

    end

  end
end
