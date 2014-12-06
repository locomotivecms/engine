module Locomotive
  class SitePolicy < ApplicationPolicy

    def create?
      membership.admin?
    end

    def update?
      @resource._id == site._id
    end

    def destroy?
      @resource._id != site._id
    end

  end
end
