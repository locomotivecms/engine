module Locomotive
  class ThemeAssetPolicy < ApplicationPolicy

    class Scope < ApplicationPolicy::Scope

      def resolve
        case membership.role
        when 'admin'
          record.theme_assets
        when 'designer'
          record.theme_assets
        when 'author'
          record.theme_assets
        when 'guest'
          []
        end
      end
    end

    def create?
      super or self.membership.to_policy(:theme_asset, user, record, membership).create?
    end

    def touch?
      not_restricted_user? or self.membership.to_policy(:theme_asset, user, record, membership).touch?
    end

  end
end
