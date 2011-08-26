# tiny patch to add middlewares after the initialization
module Rails
  class Application < Engine
    def app
      @app ||= begin
        if config.middleware.respond_to?(:merge_into)
          config.middleware = config.middleware.merge_into(default_middleware_stack)
        end
        config.middleware.build(routes)
      end
    end
  end
end


def Locomotive.configure_for_test(force = false)
  Locomotive.configure do |config|
    config.multi_sites do |multi_sites|
      multi_sites.domain = 'example.com'
      multi_sites.reserved_subdomains = %w(www admin email blog webmail mail support help site sites)
    end

    config.hosting = :none

    config.enable_logs = true

    if force
      ENV['APP_TLD'] = ENV['HEROKU_SLUG'] = ENV['APP_NAME'] = ENV['HEROKU_LOGIN'] = ENV['HEROKU_PASSWORD'] = nil

      Locomotive.define_subdomain_and_domains_options

      Object.send(:remove_const, 'Site') if Object.const_defined?('Site')
      load 'site.rb'

      FactoryGirl.factories.clear
      load File.join(Rails.root, 'spec', 'factories.rb')
    end
  end
end