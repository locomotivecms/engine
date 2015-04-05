module Locomotive
  module API
    module Entities

      class MembershipEntity < BaseEntity

        expose :role

        # render the BSON id
        expose :account_id do |membership, _|
          membership.account_id.to_s
        end

        expose :name do |membership, _|
          membership.account.name
        end

        expose :role_name do |membership, _|
          I18n.t("locomotive.memberships.roles.#{membership.role}")
        end

        expose :email do |membership, _|
          membership.account.email
        end

      end

    end
  end
end
