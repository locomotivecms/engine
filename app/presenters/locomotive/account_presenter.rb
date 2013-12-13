module Locomotive
  class AccountPresenter < BasePresenter

    ## properties ##
    properties  :name, :email, :locale, :encrypted_password, :password_salt
    property    :admin, only_getter: true

    with_options only_setter: true do |presenter|
      presenter.properties :password, :password_confirmation
    end

    ## other getters / setters ##

    def admin
      self.__source.admin?
    end

  end
end
