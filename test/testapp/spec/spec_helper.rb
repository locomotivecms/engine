ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Rspec.configure do |config|
  config.expect_with :rspec
  config.mock_with :mocha

  config.before(:each) do
    Locomotive.config.heroku = false
  end

  # require 'database_cleaner'
  # config.before(:suite) do
  #   DatabaseCleaner.strategy = :truncation
  #   DatabaseCleaner.orm = "mongoid"
  # end

  config.before(:each) do
    if self.described_class != Locomotive::Import::Job
      #DatabaseCleaner.clean
      Mongoid.master.collections.select do |collection| 
        collection.name !~ /system/ 
      end.each(&:drop)
    end
  end
end