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
end

def Locomotive.configure_for_test(force = false)
  Locomotive.configure do |config|
    config.multi_sites do |multi_sites|
      multi_sites.domain = 'example.com'
      multi_sites.reserved_subdomains = %w(www admin locomotive email blog webmail mail support help site sites)
    end

    config.enable_logs = true

    config.csrf_protection = true

    config.theme_assets_checksum = true

    config.enable_admin_ssl = false

    if force
      Locomotive.define_subdomain_and_domains_options

      Locomotive.send(:remove_const, 'Site') if Locomotive.const_defined?('Site')
      load 'locomotive/site.rb'

      FactoryGirl.factories.clear
      load File.join(File.dirname(__FILE__), 'factories.rb')
    end
  end
end
