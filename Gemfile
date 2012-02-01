#!/usr/bin/env bundle
# encoding: utf-8

source :rubygems

gemspec # Include gemspec dependencies

# The rest of the dependencies are for use when in the locomotive development environment

group :development do
  gem 'custom_fields', :path => '../gems/custom_fields' # Locale
#   # gem 'custom_fields', :git => 'git://github.com/locomotivecms/custom_fields.git', :branch => '2.0.0.rc' # Branch on Github

  gem 'rspec-rails', '2.6.1' # In order to have rspec tasks and generators
  gem 'rspec-cells'

  gem 'unicorn' # Using unicorn_rails instead of webrick (default server)
end

group :assets do
  gem 'sass-rails',   '~> 3.2.4'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '~> 1.2.3'
  gem 'compass',        :git => 'git://github.com/chriseppstein/compass.git', :branch => 'no_rails_integration'
  gem 'compass-rails',  :git => 'git://github.com/Compass/compass-rails.git'
end

group :test do
  gem 'launchy'

  gem 'autotest', :platforms => :mri
  gem 'ZenTest', :platforms => :mri

  gem 'growl-glue'

  gem 'cucumber-rails'
  gem 'rspec-rails', '2.6.1'
  gem 'shoulda-matchers'

  gem 'factory_girl_rails', '~> 1.3.0'
  gem 'pickle'
  gem 'mocha', '0.9.12' # :git => 'git://github.com/floehopper/mocha.git'

  gem 'capybara'

  gem 'xpath', '~> 0.1.4'

  gem 'database_cleaner'
end