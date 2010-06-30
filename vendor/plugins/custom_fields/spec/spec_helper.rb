$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

MODELS = File.join(File.dirname(__FILE__), 'models')
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

require 'support/mongoid'
require 'support/carrierwave'

Rspec.configure do |config|
  config.mock_with :mocha  
  config.after :suite do
    Mongoid.master.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
  end
end