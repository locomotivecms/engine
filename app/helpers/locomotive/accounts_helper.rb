module Locomotive
  module AccountsHelper

    def options_for_account
      current_site.accounts.collect { |a| ["#{a.name} <#{a.email}>", a.id.to_s] }
    end

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
