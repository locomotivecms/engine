module Locomotive
  class RegistrationsController < ::Devise::RegistrationsController

    include Locomotive::Concerns::SslController
    include Locomotive::Concerns::RedirectToMainHostController

    layout '/locomotive/layouts/account'

    before_action :configure_permitted_parameters

    helper Locomotive::BaseHelper

    before_action :set_locale

    private

    def after_sign_up_path_for(resource)
      sites_path
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    end

    def set_locale
      I18n.locale = Locomotive.config.default_locale
    end

  end
end
