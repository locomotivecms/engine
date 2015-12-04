module Locomotive
  class TranslationPolicy < ApplicationPolicy

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

    def destroy_all?
      site_staff?
    end

  end
end
