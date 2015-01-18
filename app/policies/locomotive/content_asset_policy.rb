module Locomotive
  class ContentAssetPolicy < ApplicationPolicy

    def index?
      site_staff?
    end

    def create?
      site_staff?
    end

    def update?
      site_staff?
    end

    def destroy?
      site_staff?
    end

  end
end
