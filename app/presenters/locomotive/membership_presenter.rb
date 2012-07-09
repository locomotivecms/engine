module Locomotive
  class MembershipPresenter < BasePresenter

    delegate :role, :to => :source

    delegate :role=, :account_id=, :email=, :to => :source

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
      super + %w(name email role role_name can_update grant_admin)
    end

    def included_setters
      super + %w(role account_id email)
    end

  end
end
