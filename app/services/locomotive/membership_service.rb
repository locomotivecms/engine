module Locomotive
  class MembershipService < Struct.new(:site, :policy)

    # Create a new membership for the site assigned to that service.
    # In case, no account is found from the email passed in parameter,
    # this method will return nil.
    # By default, the author role will be set to the new membership.
    #
    # @param [ String ] email The email
    #
    # @return [ Object ] A new membership (with errors or not) or nil (no account found)
    #
    def create(email)
      if account = Locomotive::Account.find_by_email(email)
        site.memberships.create(account: account, email: email)
      else
        nil
      end
    end

    # Change the role of a membership depending on the current policy.
    #
    # Accounts should not be able to set the role of another account to
    # be higher than their own.
    # A designer for example is not able to set another account to
    # be an administrator.
    #
    # @param [ String ] membership The membership to update
    # @param [ String ] role The new role
    #
    # @return [ Boolean] True if everything went well
    #
    def change_role(membership, role)
      membership.role = role if role.present?

      if role.present? && policy.change_role?
        membership.save
      else
        membership.errors.add(:role, :invalid)
        false
      end
    end

  end
end
