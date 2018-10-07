module Locomotive
  module MembershipsHelper

    def options_for_membership_roles
      roles_arr = [].tap do |options|
        current_site.roles.each do |role|
          options << [role.name.capitalize, role.id.to_s]
        end
      end
      roles_arr.sort!
    end

  end
end
