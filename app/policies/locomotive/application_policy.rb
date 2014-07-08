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

    def index?
      not_restricted_user?
    end

    alias_method :show?,      :index?
    alias_method :create?,    :index?
    alias_method :update?,    :index?
    alias_method :destroy?,   :index?

    def new?()  create? ; end
    def edit?() update? ; end

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
  end
end
