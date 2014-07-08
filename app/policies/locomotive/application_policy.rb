module Locomotive
  class ApplicationPolicy

    class Scope < Struct.new(:user)

      def resolve
        []
      end
    end

    attr_reader :user, :record

    READ_ACTIONS  = [:index, :show]
    WRITE_ACTIONS = [:create, :new, :update, :edit, :destroy]
    MANAGE_ACTIONS = READ_ACTIONS + WRITE_ACTIONS

    def initialize(user, record)
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user
      raise Pundit::NotAuthorizedError, 'must provide resource for check policy' unless record

      @user = user
      @record = record
    end

    def create?
      not_restricted_user?
    end
    alias_method :new?,    :create?
    alias_method :destroy?, :create?

    def touch?
      not_restricted_user?
    end
    alias_method :show?,   :touch?
    alias_method :edit?,   :touch?
    alias_method :update?, :touch?
    alias_method :index?,  :touch?

    def scope
      Pundit.policy_scope!(user, record.class)
    end

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

    def membership
      @membership ||= begin
        _membership = if self.record
          self.record.memberships.where(account_id: self.user.id).first
        elsif self.user.admin?
          Membership.new(account: self.user, role: 'admin')
        end
        unless _membership
          _membership = Membership.new(account: self.user, role: 'guest')
        end
        _membership
      end
    end
  end
end
