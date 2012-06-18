module Locomotive
  class AccountPresenter < BasePresenter

    delegate :name, :email, :locale, :encrypted_password, :password_salt, :to => :source

    def included_methods
      super + %w(name email locale encrypted_password password_salt)
    end

  end
end
