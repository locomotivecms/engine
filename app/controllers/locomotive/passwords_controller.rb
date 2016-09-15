module Locomotive
  class PasswordsController < ::Devise::PasswordsController

    include Locomotive::Concerns::SslController
    include Locomotive::Concerns::RedirectToMainHostController
    include Locomotive::Concerns::WithinSiteController

    within_site_only_if_existing true

    layout '/locomotive/layouts/account'

    helper Locomotive::BaseHelper

    before_filter :set_locale

    def update
      super do |resource|
        if params[:locomotive_account].try(:[], 'password').blank?
          resource.errors.add_on_blank(:password)
        end
      end
    end

    private

    def after_sending_reset_password_instructions_path_for(resource_name)
      new_locomotive_account_session_path
    end

    def set_locale
      I18n.locale = current_site? ? current_site.accounts.first.locale : Locomotive.config.default_locale
    end

  end
end
