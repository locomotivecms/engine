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

      def install_template(site, options = {})
        default_template = Boolean.set(options.delete(:default_site_template)) || false

        zipfile = options.delete(:zipfile)

        # do not try to process anything if said so
        return unless default_template || zipfile.present?

        # default template options has a higher priority than the zipfile
        source = default_template ? Locomotive.default_site_template_path : zipfile

        begin
          Locomotive::Import::Job.run!(source, site, { :samples => true })
        rescue Exception => e
          logger.error "The import of the site template failed because of #{e.message}"
        end
      end

    end
  end
end