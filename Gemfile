#!/usr/bin/env bundle
# encoding: utf-8

source "https://rubygems.org"

# net-scp 1.0.6 was yanked
gem 'net-scp', '1.0.4'

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
  # gem 'custom_fields', git: 'git://github.com/locomotivecms/custom_fields.git', branch: '2.0.0.rc' # Branch on Github

  # gem 'locomotive-aloha-rails', path: '../gems/aloha-rails' # for Developers
  # gem 'locomotive-tinymce-rails', path: '../gems/tinymce-rails' # for Developers
  # gem 'locomotive_liquid', path: '../gems/liquid' # for Developers

  gem 'unicorn' # Using unicorn_rails instead of webrick (default server)

end

group :test do
  gem 'launchy'

  gem 'cucumber-rails', require: false

  # gem 'autotest', platforms: :mri
  # gem 'ZenTest', platforms: :mri

  # gem 'growl-glue'
  gem 'poltergeist',        '~> 1.1.0'
  gem 'shoulda-matchers',   '~> 1.5.2'

  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'pickle'

  gem 'capybara',           '~> 2.0.2' #, require: false

  # gem 'xpath',              '~> 0.1.4'

  gem 'json_spec'

  gem 'database_cleaner'

  gem 'mocha', '~> 0.13.0', require: false


  # gem 'debugger', git: 'git://github.com/cldwalker/debugger.git'
end
