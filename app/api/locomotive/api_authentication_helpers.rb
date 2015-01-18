module Locomotive
  module APIAuthenticationHelpers
    include Concerns::SiteDispatcherController

    def current_user
      @current_user ||= begin
        token = headers['X-Locomotive-Account-Token']
        email = headers['X-Locomotive-Account-Email']
        Account.where(email: email, api_token: token).first
      end
    end

    def authenticate_locomotive_account!
      error!('401 Unauthorized', 401) unless current_user
    end

  end
end
