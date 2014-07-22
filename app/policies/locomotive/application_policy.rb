module Locomotive

  module AccountSiteWrapper
    def membership
      @membership ||= begin
        begin
          membership = self.site.memberships.where(account_id: self.user.id).first
          membership = Membership.new(account: self.user, role: 'admin') if self.user.admin?
          membership
        rescue
          Membership.new(account: self.user, role: 'guest')
        end

      end
    end
  end

  class ApplicationPolicy
    include AccountSiteWrapper

    class Scope < Struct.new(:user, :site, :record)
      include AccountSiteWrapper

      def resolve
        return [] unless user
        Wallet.scope(user, site, record, membership)
      end
    end

    attr_reader :user, :site, :record

    READ_ACTIONS  = [:index, :show]
    WRITE_ACTIONS = [:create, :new, :update, :edit, :destroy]
    MANAGE_ACTIONS = READ_ACTIONS + WRITE_ACTIONS

    def initialize(user, site, record=nil)
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user

      @user   = user
      @site   = site
      @record = record
    end

    def create?
      return true if not_restricted_user? or Wallet.authorized?(user, :create, record, membership)
      raise Pundit::NotAuthorizedError.new("not allowed to create #{record} for #{user.email}")
    end
    alias_method :new?,    :create?
    alias_method :destroy?, :create?

    def touch?
      return true if not_restricted_user? or Wallet.authorized?(user, :touch, record, membership)
      raise Pundit::NotAuthorizedError.new("not allowed to modify #{record} for #{user.email}")
    end
    alias_method :show?,   :touch?
    alias_method :edit?,   :touch?
    alias_method :update?, :touch?
    alias_method :index?,  :touch?

    # For any actions without setting return false as fallback
    def method_missing(method, *args, &block)
      if self.class.method_defined? method
        self.public_send method, *args, &block
      elsif method.to_s =~ /\?$/
        false # fallback as unauthorized
      else
        super
      end
    end

    protected

    def not_restricted_user?
      user and user.is_admin?
    end
  end
end
