module Locomotive
  module Extensions
    module Site
      module FirstInstallation

        extend ActiveSupport::Concern

        # included do

        #   ## virtual attributes ##
        #   attr_accessor :first_locale

        # end

        def first_locale=(locale)
          self.locales = [locale]
        end

        def first_locale
          self.default_locale
        end

        module ClassMethods

          # only called during the installation workflow, just after the admin account has been created
          def create_first_one(attributes)
            site = self.new(attributes)
            account = Account.first
            site.memberships.build account: account, role: 'admin'

            site.save

            account.locale = site.default_locale
            account.save

            site
          end

        end

      end
    end
  end
end