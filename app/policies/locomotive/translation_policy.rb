module Locomotive
  class TranslationPolicy < ApplicationPolicy

    def index?
      site_staff?
    end

    def new?
      site_staff?
    end

    def edit?
      site_staff?
    end

    def create?
      site_staff? && !membership.visitor?
    end

    def update?
      site_staff? && !membership.visitor?
    end

    def destroy?
      site_staff? && !membership.visitor?
    end

    def destroy_all?
      site_staff? && !membership.visitor?
    end

  end
end
