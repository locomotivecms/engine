module Locomotive
  class ApplicationPolicy

    class Scope

      attr_reader :membership, :scope

      def initialize(membership, scope)
        @membership = membership
        @scope      = scope
      end

    end

    delegate :site, :account, to: :membership

    attr_reader :membership, :resource

    # The resource is always scoped by the site defined by the membership.
    def initialize(membership, resource)
      @membership = membership
      @resource   = resource

      raise Pundit::NotAuthorizedError, 'must be logged in' unless account
      raise Pundit::NotAuthorizedError, 'should have a resource' unless resource

      # if site.nil?
      #   unless account.super_admin? || resource.is_a?(Locomotive::Account)
      #     raise Pundit::NotAuthorizedError, 'should have a site'
      #   end
      # end
    end

    def index?
      false
    end

    def show?
      index?
    end

    def edit?
      update?
    end

    def update?
      false
    end

    def new?
      create?
    end

    def create?
      false
    end

    def destroy?
      false
    end

    def destroy_all?
      false
    end

    def site_staff?
      membership.site.present?
    end

    def super_admin?
      account.super_admin?
    end

    def site_admin_or_designer?
      membership.admin? || membership.designer?
    end

    def site_admin?
      membership.admin?
    end

  end
end
