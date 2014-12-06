module Locomotive
  class ContentTypePolicy < ApplicationPolicy

    def index?
      true
    end

    def create?
      local_admin?
    end

    def update?
      local_admin?
    end

    def destroy?
      local_admin?
    end

  end
end
