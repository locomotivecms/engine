# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  # config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  config.before(:each) do
    Locomotive.config.heroku = false
  end

  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
  end

  config.before(:each) do
    if self.described_class != Locomotive::Import::Job
      DatabaseCleaner.clean
    end
  end
end


# # This file is copied to ~/spec when you run 'ruby script/generate rspec'
# # from the project root directory.
# ENV["RAILS_ENV"] ||= 'test'
# require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
# require 'rspec/rails'
#
# # Requires supporting files with custom matchers and macros, etc,
# # in ./support/ and its subdirectories.
# Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
#
# Rspec.configure do |config|
#   config.expect_with :rspec
#   config.mock_with :mocha
#
#   config.before(:each) do
#     Locomotive.config.heroku = false
#   end
#
#   require 'database_cleaner'
#   config.before(:suite) do
#     DatabaseCleaner.strategy = :truncation
#     DatabaseCleaner.orm = "mongoid"
#   end
#
#   config.before(:each) do
#     if self.described_class != Locomotive::Import::Job
#       DatabaseCleaner.clean
#     end
#   end
# end
