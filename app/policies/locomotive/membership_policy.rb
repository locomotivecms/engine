module Locomotive
  class MembershipPolicy < ApplicationPolicy

    def create?
      local_admin?
    end

    def destroy?
      local_admin?
    end

  end
end
