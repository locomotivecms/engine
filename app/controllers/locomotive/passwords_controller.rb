module Locomotive
  class PasswordsController < ::Devise::PasswordsController

    include Locomotive::Concerns::WithinSiteController

    within_site_only_if_existing

    layout '/locomotive/layouts/not_logged_in'

    helper Locomotive::BaseHelper

    private

    def after_sending_reset_password_instructions_path_for(resource_name)
      new_locomotive_account_session_path
    end

  end
end
