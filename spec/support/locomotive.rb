module Locomotive
  module TestHelpers

    def request_site(site)
      @request.env['locomotive.site'] = site
    end

    def account_token(account)
      account.ensure_authentication_token
      account.save
      account.authentication_token
    end

  end

  module TestViewHelpers

    def current_site
    end

    def policy(object = nil)
    end

    def current_locomotive_account
    end

    def last_saved_location
    end

    def translation_nav_params
    end

  end
end

def Locomotive.configure_for_test(force = false)
  Locomotive.configure do |config|
    config.enable_logs = true

    config.enable_admin_ssl = false

    if force
      Locomotive.send(:remove_const, 'Site') if Locomotive.const_defined?('Site')
      load 'locomotive/site.rb'
    end
  end
end

