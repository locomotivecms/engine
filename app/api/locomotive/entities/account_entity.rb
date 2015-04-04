module Locomotive
  module API

    class AccountEntity < BaseEntity

      expose  :name, :email, :locale, :encrypted_password, :password_salt, :api_key,
              :super_admin, :password, :password_confirmation

      expose :local_admin do |account, _|
        account.local_admin?
      end

    end

  end
end
