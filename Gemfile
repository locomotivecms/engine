#!/usr/bin/env bundle
# encoding: utf-8

source "https://rubygems.org"

gemspec # Include gemspec dependencies

gem 'sass-rails',   '~> 5.0.1'
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
  # gem 'custom_fields', github: 'locomotivecms/custom_fields', ref: '15cceb66ed'

  # gem 'locomotivecms_steam', path: '../in_progress/steam', require: false
  gem 'locomotivecms_steam', github: 'locomotivecms/steam', ref: '552b013e147ef', require: false

  # gem 'locomotive-aloha-rails', path: '../gems/aloha-rails' # for Developers
  # gem 'locomotive-tinymce-rails', path: '../gems/tinymce-rails' # for Developers
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
end

group :profile, :development do
  gem 'ruby-prof'
end

group :test do
  # gem 'launchy'
  # gem 'capybara',           '~> 2.0.2'
  # gem 'cucumber-rails', require: false
  gem 'simplecov'

  gem 'capybara',             '~> 2.4.4'
  gem 'poltergeist'

  gem 'grape-entity-matchers'
  gem 'shoulda-matchers',     '2.7.0'

  gem 'factory_girl_rails'
  gem 'pickle'
  gem 'json_spec',            '~> 1.1.4'
  gem 'database_cleaner',     '~> 1.4.1'
  gem 'timecop',              '~> 0.7.1'

  # gem 'debugger', git: 'git://github.com/cldwalker/debugger.git'
end
