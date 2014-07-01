module Locomotive
  class ApplicationPolicy
    attr_reader :user, :record

    READ_ACTIONS  = [:index, :show]
    WRITE_ACTIONS = [:create, :new, :update, :edit, :destroy]
    MANAGE_ACTIONS = READ_ACTIONS + WRITE_ACTIONS

    def initialize(user, record)
      # raise Pundit::NotAuthorizedError, 'must be logged in' unless user
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

    protected

    def not_restricted_user?
      user and user.is_admin?
    end
  end
end
