module Locomotive
  class AccountPresenter < BasePresenter

    delegate :name, :email, :locale, :encrypted_password, :password_salt, :to => :source

    delegate :name=, :email=, :locale=, :password=, :to => :source

    attr_writer :encrypted_password, :password_salt

    def admin
      self.source.admin?
    end

    def included_methods
      super + %w(name email locale admin encrypted_password password_salt)
    end

    def included_setters
      super + %w(name email locale password encrypted_password password_salt)
    end

    def save
      if @encrypted_password && @password_salt
        # Just need something that will pass the password validation
        self.source.password = '0' * 20
        self.source.encrypted_password = @encrypted_password
        self.source.password_salt = @password_salt
      end
      super
    end

  end
end
