module Locomotive
  class MembershipsService

    attr_reader :ability

    def initialize(ability)
      @ability = ability
    end

    def change_role(membership, role)
      if role.to_sym == :admin && ability.cannot?(:grant_admin, membership)
        raise CanCan::AccessDenied.new('Not authorized!', :grant_admin, membership)
      end

      if ability.can?(:update, membership)
        membership.update_attribute :role, role
      end
    end

  end
end