ENV['RAILS_ENV'] ||= 'test'

require File.join(File.dirname(__FILE__), 'dummy', 'config', 'environment.rb')
require 'rspec/rails'
require 'rspec/autorun'
require 'mocha/setup'
require 'rails/mongoid'
require 'factory_girl'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |f| require f }

Locomotive.configure_for_test

RSpec.configure do |config|

  config.include(Locomotive::RSpec::Matchers)

  config.mock_with :mocha

  config.infer_base_class_for_anonymous_controllers = false

  # config.order = 'random'

  config.before(:suite) do
    Locomotive.configure_for_test(true)
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = 'mongoid'
  end

  config.before(:each) do
    Mongoid::IdentityMap.clear
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end
end