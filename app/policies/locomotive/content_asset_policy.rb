module Locomotive
  class ContentAssetPolicy < ApplicationPolicy

    class Scope < ApplicationPolicy::Scope

      def resolve
        case membership.role
        when 'admin'
          record.content_assets
        when 'designer'
          record.content_assets
        when 'author'
          record.content_assets
        when 'guest'
          []
        end
      end
    end

    def create?
      super or self.membership.to_policy(:content_asset, user, record, membership).create?
    end

    def touch?
      not_restricted_user? or self.membership.to_policy(:content_asset, user, record, membership).touch?
    end

  end
end
