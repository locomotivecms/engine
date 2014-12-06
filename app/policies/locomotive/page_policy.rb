module Locomotive
  class PagePolicy < ApplicationPolicy

    def index?
      true
    end

    def create?
      true
    end

    def update?
      true
    end

    def destroy?
      local_admin?
    end

  end
end
