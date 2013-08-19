#!/usr/bin/env bundle
# encoding: utf-8

source "https://rubygems.org"

gemspec # Include gemspec dependencies

group :assets do
  gem 'sass-rails',   '~> 3.2.4'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '~> 1.2.4'
  gem 'compass-rails'
end

# The rest of the dependencies are for use when in the locomotive development / test environments

group :test, :development do
  gem 'rspec-rails', '~> 2.13.0' # In order to have rspec tasks and generators
  gem 'rspec-cells'
end

group :development do
  # gem 'custom_fields', path: '../gems/custom_fields' # for Developers
  # gem 'custom_fields', github: 'locomotivecms/custom_fields'
  # gem 'custom_fields', git: 'git://github.com/locomotivecms/custom_fields.git', branch: '2.0.0.rc' # Branch on Github

  # gem 'locomotive-aloha-rails', path: '../gems/aloha-rails' # for Developers
  # gem 'locomotive-tinymce-rails', path: '../gems/tinymce-rails' # for Developers
  # gem 'locomotive_liquid', path: '../gems/liquid' # for Developers
  # gem 'locomotivecms_solid', path: '../gems/solid' # for Developers

  # gem 'carrierwave-mongoid', git: 'git://github.com/locomotivecms/carrierwave-mongoid.git'

  gem 'thor'
  gem 'github_api'

  gem 'unicorn' # Using unicorn_rails instead of webrick (default server)

end

group :test do
  gem 'launchy'

  gem 'cucumber-rails', require: false

  # gem 'autotest', platforms: :mri
  # gem 'ZenTest', platforms: :mri

  gem 'poltergeist',        '~> 1.1.0'
  gem 'shoulda-matchers',   '~> 1.5.2'

  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'pickle'

  gem 'capybara',           '~> 2.0.2'

  gem 'json_spec'

  gem 'database_cleaner'

  gem 'mocha', '~> 0.13.0', require: false

  # gem 'debugger', git: 'git://github.com/cldwalker/debugger.git'
end
