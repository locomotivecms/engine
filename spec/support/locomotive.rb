# tiny patch to add middlewares after the initialization
# module Rails
#   class Application < Engine
#     def app
#       @app ||= begin
#         if config.middleware.respond_to?(:merge_into)
#           config.middleware = config.middleware.merge_into(default_middleware_stack)
#         end
#         config.middleware.build(routes)
#       end
#     end
#   end
# end


def Locomotive.configure_for_test(force = false)
  Locomotive.configure do |config|
    config.multi_sites do |multi_sites|
      multi_sites.domain = 'example.com'
      multi_sites.reserved_subdomains = %w(www admin locomotive email blog webmail mail support help site sites)
    end

    config.enable_logs = true

    config.csrf_protection = true

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
