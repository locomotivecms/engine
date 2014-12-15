module Locomotive
  module MembershipsHelper

    def options_for_membership_roles(membership)
      current_role = membership.role

      [].tap do |options|
        Locomotive::Membership::ROLES.each do |role|
          membership.role = role
          if policy(membership).change_role?
            options << [t("locomotive.memberships.roles.#{role}"), role.to_s]
          end
        end
        membership.role = current_role
      end
    end

  end
end
