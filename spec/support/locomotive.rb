def Locomotive.configure_for_test
  Locomotive.configure do |config|
    config.multi_sites do |multi_sites|
      multi_sites.domain = 'example.com'
      multi_sites.reserved_subdomains = %w(www admin email blog webmail mail support help site sites)
    end
    config.hosting = :none
    config.enable_logs = true
  end
end