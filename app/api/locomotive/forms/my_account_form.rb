module Locomotive
  class MyAccountForm < BaseForm
    attrs :name, :email, :locale, :api_key, :password, 
          :password_confirmation
  end
end
