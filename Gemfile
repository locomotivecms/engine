source 'https://rubygems.org'

# Declare your gem's dependencies in locomotive.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :development, :test do
  gem 'rspec-rails',  '~> 3.8.0'
  gem 'capybara',     '~> 3.25.0'

  # To use a debugger
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development, :test do
  # gem 'custom_fields', path: '../custom_fields' # for Developers
  # gem 'custom_fields', github: 'locomotivecms/custom_fields', ref: '73b666d'

  # gem 'locomotivecms_common', path: '../common', require: false
  # gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '4d1bd56', require: false

  # gem 'locomotivecms_steam', path: '../steam', require: false
  gem 'locomotivecms_steam', github: 'locomotivecms/steam', ref: '02edd6b', require: false

  # gem 'carrierwave-mongoid', git: 'git://github.com/locomotivecms/carrierwave-mongoid.git'
end

group :test do
  gem 'selenium-webdriver',       '~> 3.142.3'
  gem 'puma',                     '~> 4.3.3'
  gem 'webdrivers',               '~> 4.1.0'

  gem 'grape-entity-matchers',    github: 'salsify/grape-entity-matchers', branch: 'grape-entity-exposures'
  gem 'shoulda-matchers',         '~> 3.1.2'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'factory_bot_rails',        '~> 4.11.1'
  gem 'json_spec',                '~> 1.1.5'
  gem 'database_cleaner',         '~> 1.6.2'
  gem 'email_spec',               '~> 2.2.0'

  gem 'codeclimate-test-reporter',  '~> 1.0.7',  require: false
  gem 'simplecov',                  require: false
end
