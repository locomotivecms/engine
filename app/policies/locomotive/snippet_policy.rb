module Locomotive
  class SnippetPolicy < ApplicationPolicy

    def index?
      local_admin?
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
