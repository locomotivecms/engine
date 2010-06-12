Locomotive.configure do |config|
  # if not defined, locomotive will use example.com as main domain name. Remove prefix www from your domain name.
  # Ex:
  # config.default_domain = Rails.env.production? ? 'mydomain.com' : 'example.com'
  config.default_domain = 'mydomain.com'
  
  # configure how many items we display in sub menu in the "Contents" section. 
  config.lastest_items_nb = 5
  
  # tell if logs are enabled. Useful for debug purpose.
  config.enable_logs = true
end