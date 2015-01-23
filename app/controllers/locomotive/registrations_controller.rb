module Locomotive
  class RegistrationsController < ::Devise::RegistrationsController

    layout '/locomotive/layouts/not_logged_in'

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
