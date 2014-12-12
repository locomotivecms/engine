module Locomotive
  class MembershipPresenter < BasePresenter

    ## properties ##

    property    :role
    properties  :role_name, :can_update, :grant_admin, only_getter: true
    property    :account_id
    property    :name, only_getter: true
    property    :email

    ## other getters / setters ##

    def name
      self.__source.account.name
    end

    def role_name
      I18n.t("locomotive.memberships.roles.#{self.__source.role}")
    end

    def email
      self.__source.account.email
    end

    def can_update
      self.__policy.try(:touch?)
    end

    def grant_admin
      self.__policy.try(:grant_admin?)
    end

  end
end
