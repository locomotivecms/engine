#!/usr/bin/env bundle
# encoding: utf-8

source :rubygems

gemspec # Include gemspec dependencies

# The rest of the dependencies are for use when in the locomotive development environment

group :development do
  gem 'custom_fields', :path => '../gems/custom_fields' # Locale
  # gem 'custom_fields', :git => 'git://github.com/locomotivecms/custom_fields.git', :branch => '2.0.0.rc' # Branch on Github
end

group :test do
  gem 'launchy',            '~> 2.0.5'

  gem 'autotest',           '~> 4.4.6', :platforms => :mri

  gem 'cucumber-rails',     '~> 1.2.1'
  gem 'shoulda-matchers',   '~> 1.0.0'

  gem 'factory_girl_rails', '~> 1.3.0'
  gem 'pickle',             '~> 0.4.10'
  gem 'mocha',              '~> 0.9.12' # :git => 'git://github.com/floehopper/mocha.git'

  gem 'database_cleaner',   '~> 0.7.1'
end

group :production do
  gem 'bushido', '~> 0.0.35'
end

group :mac_development do
  gem 'growl-glue', '~> 1.0.7'
end