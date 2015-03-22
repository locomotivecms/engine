module Locomotive
  class MyAccountForm < BaseForm
    attrs :name, :email, :locale, :api_key, :super_admin, :password, 
          :password_confirmation
  end
end
