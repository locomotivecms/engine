module Locomotive
  module API
    module Forms

      class MembershipForm < BaseForm
        attrs :account_id, :role, :account_email

        attr_accessor :site

        def initialize(site, attributes = {})
          self.site = site
          super(attributes)
        end

        # @note if account_email is set, use it to find the account.
        def account_email=(email)
          self.account_id = Account.find_by(email: email).try(:_id)
          set_attribute(:account_email, email)
        end
      end

    end
  end
end
