module Locomotive
  class RegistrationsController < ::Devise::RegistrationsController

    include Locomotive::Concerns::SslController
    include Locomotive::Concerns::RedirectToMainHostController

    layout '/locomotive/layouts/account'

    before_action :configure_permitted_parameters

    helper Locomotive::BaseHelper

    private

    def after_sign_up_path_for(resource)
      sites_path
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :name
    end

  end
end
