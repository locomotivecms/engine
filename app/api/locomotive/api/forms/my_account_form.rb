module Locomotive
  module API

    class MyAccountForm < BaseForm
      attrs :name, :email, :locale, :api_key, :password,
            :password_confirmation
    end

  end
end
