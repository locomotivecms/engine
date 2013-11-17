require 'locomotive/liquid/drops/base'
require 'locomotive/liquid/drops/proxy_collection'
require 'locomotive/liquid/filters/base'
require 'locomotive/liquid/tags/hybrid'
require 'locomotive/liquid/tags/path_helper'

%w{. tags drops filters}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each { |lib| require lib }
end