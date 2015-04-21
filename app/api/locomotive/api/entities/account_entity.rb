module Locomotive
  module API
    module Entities

      class AccountEntity < BaseEntity

        expose  :name, :email, :locale, :api_key, :super_admin

        expose :local_admin do |account, _|
          account.local_admin?
        end

      end

    end
  end
end
