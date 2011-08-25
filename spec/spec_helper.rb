# Note: if segmentation fault with spork / imagemagick on mac os x, take a look at:
# http://stackoverflow.com/questions/2838307/why-is-this-rmagick-call-generating-a-segmentation-fault

require 'rubygems'
require 'spork'

# figure out where we are being loaded from
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec/spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end


Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'

  # Avoid preloading models
  require 'rails/mongoid'
  Spork.trap_class_method(Rails::Mongoid, :load_models)

  require File.expand_path('../../config/environment', __FILE__)

  require 'rspec/rails'

  require 'factory_girl'
  Spork.trap_class_method(FactoryGirl, :find_definitions)

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

  Locomotive.configure_for_test

  RSpec.configure do |config|

    config.include(Locomotive::RSpec::Matchers)

    config.mock_with :mocha

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

end

Spork.each_run do
  # This code will be run each time you run your specs.
  Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

  # loading ruby file directly breaks the tests
  # Dir[Rails.root.join('app/models/*.rb')].each { |f| load f }
end