module Locomotive
  class SnippetPolicy < ApplicationPolicy
    class Scope < Struct.new(:user)

      def resolve
        self.user.to_scope(:site).resolve
      end
    end

    def create?
      super or self.membership.to_policy(:site, user, record, membership).create?
    end

    def touch?
      not_restricted_user? or self.membership.to_policy(:site, user, record, membership).touch?
    end
  end
end
