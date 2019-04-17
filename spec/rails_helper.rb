# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path("../../spec/dummy/config/environment.rb", __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
require 'rails/mongoid'
require 'pundit/rspec'
require 'email_spec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each { |f| require f }

Locomotive.configure_for_test

RSpec.configure do |config|

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include Rails.application.routes.url_helpers
  config.before :each, type: :helper do
    helper.class.include Locomotive::Engine.routes.url_helpers
  end

  # Replace Timecop
  config.include ActiveSupport::Testing::TimeHelpers

  config.include Features::SessionHelpers,  type: :system
  config.include Features::SiteHelpers,     type: :system
  config.include Features::Matchers,        type: :system
  config.include EmailSpec::Helpers,        type: :system
  config.include EmailSpec::Matchers,       type: :system

  config.include Locomotive::RSpec::Matchers
  config.include Locomotive::TestHelpers,           type: :controller

  config.include RSpec::Rails::RequestExampleGroup, type: :request, file_path: /spec\/api/

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

  config.before(:each, type: :controller) do
    request.host = 'locomotive.local' if request.respond_to?(:host=)
  end

  config.before(:each, type: :system) do
    host! 'http://locomotive.local'
    driven_by :locomotive_headless_chrome
  end
end
