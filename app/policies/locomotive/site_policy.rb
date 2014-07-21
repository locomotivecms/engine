module Locomotive
  class SitePolicy < ApplicationPolicy

    class Scope < Struct.new(:request)

      def resolve
        if Locomotive.config.multi_sites?
          @current_site ||= Locomotive::Site.match_domain(request.host).first
        else
          @current_site ||= Locomotive::Site.first
        end
      end
    end

    def show?
      true
    end

    def update?
      super or Wallet.authorized?(user, record, :touch)
      # super or self.membership.to_policy(:site, user, record, membership).touch?
    end
    alias_method :destroy?, :update?

  end
end
