$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

MODELS = File.join(File.dirname(__FILE__), "models")
$LOAD_PATH.unshift(MODELS)

require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

require 'mongoid'
require 'mocha'
require 'rspec'
require 'custom_fields'

Dir[ File.join(MODELS, "*.rb") ].sort.each { |file| require File.basename(file) }

Mongoid.configure do |config|
  name = "custom_fields_test"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  # config.master = Mongo::Connection.new('localhost', '27017', :logger => Logger.new($stdout)).db(name)
end

Rspec.configure do |config|
  config.mock_with :mocha  
  config.after :suite do
    Mongoid.master.collections.each(&:drop)
  end
end