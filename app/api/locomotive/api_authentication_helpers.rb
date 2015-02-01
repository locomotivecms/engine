module Locomotive
  module APIAuthenticationHelpers
    include Concerns::SiteDispatcherController

    def current_account
      @current_user ||= begin
        token = headers['X-Locomotive-Account-Token']
        email = headers['X-Locomotive-Account-Email']
        Account.where(email: email, api_token: token).first
      end
    end

    def authenticate_locomotive_account!
      error!('401 Unauthorized', 401) unless current_user
      true
    end

    def current_site
      @current_site ||= request.env['locomotive.site']
    end

    def current_user
      membership = @site ? @site.membership_for(current_account) : nil
      membership || Locomotive::Membership.new(account: current_account)
    end

    def authorize(obj)
      policy = policy_for(obj)
      error!("user unauthorized for this") unless policy_for(obj).new(current_user, obj)
      true
    end

    private

    def policy_for(obj)
      locomotive_klass = model_klass(obj)
      "#{locomotive_klass}Policy".constantize
    end

    def model_klass(obj)
      model_name = obj.model_name.to_s
      model_name.classify
    end
  end
end
