module Locomotive
  module API
    module Forms

      class MembershipForm < BaseForm
        attrs :account_id, :role

        attr_accessor :site
        attr_reader   :account_email

        def initialize(site, attributes = {})
          self.site = site
          super(attributes)
        end

        def account_email=(email)
          self.account_id = Account.find_by(email: email).try(:_id)
          @account_email = email
        end
      end

    end
  end
end
