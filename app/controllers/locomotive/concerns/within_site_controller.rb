module Locomotive
  module Concerns

    # When called, the within_site method enhances the controller by:
    #
    #   - checking if the user is requesting an existing Locomotive site
    #   - checking if the user is a member of this site (can be disabled)
    #   - setting the current timezone defined by the site
    #
    # Thus, this module requires the follow concerns:
    #   - SiteDispatcher
    #   - Membership
    #   - Timezone
    #
    module WithinSiteController

      extend ActiveSupport::Concern

      included do

        include Locomotive::Concerns::SiteDispatcherController
        include Locomotive::Concerns::TimezoneController
        include Locomotive::Concerns::MembershipController
        include Locomotive::Concerns::LocaleHelpersController

        helper  Locomotive::Shared::SitesHelper,
                Locomotive::Shared::AccountsHelper,
                Locomotive::Shared::PagesHelper,
                Locomotive::Shared::SiteMetafieldsHelper,
                Locomotive::ContentTypesHelper

      end

      module ClassMethods

        def within_site_only_if_existing(guest = false)
          within_site(false, guest)
        end

        def within_site_but_as_guest
          within_site(true, true)
        end

        def within_site(required = true, guest = false)
          class_eval do
            before_action :require_site if required

            unless guest
              before_action :validate_site_membership, if: :current_site?
            end

            around_action :set_timezone, if: :current_site?

            before_action :set_current_content_locale, if: :current_site?
          end
        end

      end
    end

  end
end
