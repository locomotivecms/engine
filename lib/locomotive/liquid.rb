require 'locomotive/liquid/drops/base'
require 'locomotive/liquid/drops/proxy_collection'

%w{. tags drops filters}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each { |lib| require lib }
end