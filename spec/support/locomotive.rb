def Locomotive.configure_for_test(force = false)
  Locomotive.configure do |config|
    config.multi_sites do |multi_sites|
      multi_sites.domain = 'example.com'
      multi_sites.reserved_subdomains = %w(www admin email blog webmail mail support help site sites)
    end

    config.hosting = :none

    config.enable_logs = true

    if force
      Locomotive.define_subdomain_and_domains_options

      Object.send(:remove_const, 'Site') if Object.const_defined?('Site')
      load 'site.rb'

      Factory.factories.clear
      load File.join(Rails.root, 'spec', 'factories.rb')
    end
  end
end