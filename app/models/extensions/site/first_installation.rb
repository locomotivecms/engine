module Extensions
  module Site
    module FirstInstallation

      # only called during the installation workflow, just after the admin account has been created
      def create_first_one(attributes)
        site = self.new(attributes)

        site.memberships.build :account => Account.first, :admin => true

        site.save

        site
      end

    end
  end
end