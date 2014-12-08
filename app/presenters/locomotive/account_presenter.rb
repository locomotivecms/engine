module Locomotive
  class AccountPresenter < BasePresenter

    ## properties ##
    properties  :name, :email, :locale, :encrypted_password, :password_salt, :api_key
    property    :super_admin, only_getter: true
    property    :local_admin, only_getter: true

    with_options only_setter: true do |presenter|
      presenter.properties :password, :password_confirmation
    end

    ## other getters / setters ##

    def local_admin
      self.__source.local_admin?
    end

  end
end
