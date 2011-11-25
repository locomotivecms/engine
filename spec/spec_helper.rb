ENV["RAILS_ENV"] ||= 'test'

require 'rails/mongoid'
require File.join(File.dirname(__FILE__), 'dummy', 'config', 'environment.rb')
require 'rspec/rails'
require 'factory_girl'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |f| require f }

Locomotive.configure_for_test

RSpec.configure do |config|

  config.include(Locomotive::RSpec::Matchers)

  config.mock_with :mocha

  config.before(:suite) do
    Locomotive.configure_for_test(true)
  end

  config.before(:each) do
    Locomotive.config.heroku = false
  end

  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = 'mongoid'
  end

  config.before(:each) do
    if self.described_class != Locomotive::Import::Job
      DatabaseCleaner.clean
    end
  end

  config.before(:all) do
    if self.described_class == Locomotive::Import::Job
      DatabaseCleaner.clean
    end
  end
end
