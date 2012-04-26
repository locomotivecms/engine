module Locomotive
  class MembershipPresenter < BasePresenter

    delegate :role, :account_id, :to => :source

    def name
      self.source.account.name
    end

    def role_name
      I18n.t("locomotive.memberships.roles.#{self.source.role}")
    end

    def email
      self.source.account.email
    end

    def can_update
      return nil unless self.ability?
      self.ability.can? :update, self.source
    end

    def grant_admin
      return nil unless self.ability?
      self.ability.can? :grant_admin, self.source
    end

    def included_methods
      super + %w(account_id name email role role_name can_update grant_admin)
    end

    # def light_as_json
    #   methods = included_methods.clone - %w(name email)
    #   self.as_json(methods)
    # end

  end
end