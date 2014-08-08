#!/usr/bin/env bundle
# encoding: utf-8

source "https://rubygems.org"

gemspec # Include gemspec dependencies

gem 'sass-rails',   '~> 4.0.3'
gem 'coffee-rails', '~> 4.0.1'
gem 'uglifier',     '>= 2.5.3'

# The rest of the dependencies are for use when in the locomotive development / test environments
gem 'activeresource'

gem 'bson'
gem 'moped', github: 'mongoid/moped'

# add these gems to help with the transition:
gem 'protected_attributes'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'

group :test, :development do
  gem 'rspec-rails', '~> 2.14.2' # In order to have rspec tasks and generators
  gem 'rspec-cells', '0.1.10' # Can't update more because rspec-cells depends on rspec >= 2.99 after this version
  gem 'pry'
end

group :development do
  # gem 'custom_fields', path: '../custom_fields'
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

  gem 'unicorn-rails' # Using unicorn_rails instead of webrick (default server)

end

group :test do
  gem 'launchy'

  gem 'cucumber-rails', require: false

  # gem 'autotest', platforms: :mri
  # gem 'ZenTest', platforms: :mri

  gem 'poltergeist'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'pickle'

  gem 'capybara',           '~> 2.0.2'

  gem 'json_spec'

  gem 'database_cleaner'

  gem 'mocha', require: false

  # gem 'debugger', git: 'git://github.com/cldwalker/debugger.git'
end
