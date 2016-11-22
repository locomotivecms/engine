#!/usr/bin/env bundle
# encoding: utf-8

source "https://rubygems.org"

gemspec # Include gemspec dependencies

gem 'sass-rails', '~> 5.0.4'
gem 'coffee-rails', '~> 4.1.0'
gem 'uglifier',     '>= 2.5.3'

gem 'coveralls',    '~> 0.7.2', require: false

group :test, :development do
  gem 'rspec-rails', '~> 3.2.1' #~> 2.14.2' # In order to have rspec tasks and generators
  gem 'pry'
end

group :development do
  # gem 'custom_fields', path: '../custom_fields'
  # gem 'custom_fields', path: '../gems/custom_fields' # for Developers
  # gem 'custom_fields', github: 'locomotivecms/custom_fields', ref: 'b5dcac5'

  # gem 'locomotivecms_common', path: '../gems/common', require: false
  # gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '257047b', require: false

  # gem 'locomotivecms_steam', path: '../gems/steam', require: false
  # gem 'locomotivecms_steam', github: 'locomotivecms/steam', ref: 'a2cba33', require: false

  # gem 'locomotive_liquid', path: '../gems/liquid' # for Developers
  # gem 'locomotivecms_solid', path: '../gems/solid' # for Developers

  # gem 'carrierwave-mongoid', git: 'git://github.com/locomotivecms/carrierwave-mongoid.git'

  gem 'thor'

  gem 'quiet_assets'

  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-byebug'

  # gem 'unicorn-rails' # Using unicorn_rails instead of webrick (default server)
  # gem 'thin'
  gem 'puma'

  # i18n-tasks helps you find and manage missing and unused translations.
  gem 'i18n-tasks', '~> 0.8.7'
end

group :profile, :development do
  gem 'ruby-prof'
end

group :test do
  gem 'simplecov'

  gem 'capybara-webkit',      '~> 1.10.1'

  gem 'grape-entity-matchers'
  gem 'shoulda-matchers',     '2.7.0'

  gem 'factory_girl_rails'
  gem 'pickle'
  gem 'json_spec',            '~> 1.1.4'
  gem 'database_cleaner',     github: 'DatabaseCleaner/database_cleaner'
  gem 'timecop',              '~> 0.7.1'

  gem 'email_spec'

  # gem 'debugger', git: 'git://github.com/cldwalker/debugger.git'
end
