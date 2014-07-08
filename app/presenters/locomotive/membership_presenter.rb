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
      return nil unless self.ability?
      self.__ability.update?
    end

    def grant_admin
      return nil unless self.ability?
      self.__ability.grant_admin?
    end

  end
end
