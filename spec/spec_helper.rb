# require 'coveralls'
# Coveralls.wear!('rails')
require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'

require File.join(File.dirname(__FILE__), 'dummy', 'config', 'environment.rb')
require 'rspec/rails'
require 'rails/mongoid'
require 'factory_girl'
require 'pundit/rspec'
require 'email_spec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |f| require f }

Locomotive.configure_for_test

RSpec.configure do |config|

  config.include Rails.application.routes.url_helpers
  config.before :each, type: :helper do
    helper.class.include Locomotive::Engine.routes.url_helpers
  end

  config.include Features::SessionHelpers,  type: :feature
  config.include Features::SiteHelpers,     type: :feature
  config.include EmailSpec::Helpers,        type: :feature
  config.include EmailSpec::Matchers,       type: :feature

  config.include Locomotive::RSpec::Matchers
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include Locomotive::TestHelpers, type: :controller
  config.include RSpec::Rails::RequestExampleGroup, type: :request, file_path: /spec\/api/

  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = false

  config.before(:suite) do
    Locomotive.configure_for_test(true)
  end

  config.before(:suite) do
    DatabaseCleaner.clean
  end

  config.before(:each) do
    ::Mongoid::Fields::I18n.clear_fallbacks
    I18n.locale = Mongoid::Fields::I18n.locale = 'en'
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
  # config.seed = '5581' # example
  # config.seed = '50337'
end
