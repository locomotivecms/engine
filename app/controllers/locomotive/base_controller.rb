module Locomotive
  class BaseController < ApplicationController

    include Locomotive::ActionController::Ssl
    include Locomotive::Concerns::UrlHelpersController

    include Locomotive::Concerns::AccountController
    include Locomotive::Concerns::ExceptionController
    include Locomotive::Concerns::AuthorizationController
    include Locomotive::Concerns::StoreLocationController
    include Locomotive::Concerns::WithinSiteController

    layout '/locomotive/layouts/application'

    before_filter :require_ssl

    helper Locomotive::BaseHelper, Locomotive::ErrorsHelper

    self.responder = Locomotive::ActionController::Responder # custom responder

    respond_to :html

  end
end
