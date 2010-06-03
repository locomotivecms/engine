require File.dirname(__FILE__) + '/../../lib/locomotive.rb'
require File.dirname(__FILE__) + '/../../lib/core_ext.rb'

Locomotive.configure do |config|
  config.default_domain = 'example.com'
  config.lastest_items_nb = 5
end