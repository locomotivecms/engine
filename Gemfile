source 'https://rubygems.org'

# Declare your gem's dependencies in locomotive.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :test, :development do
  gem 'rspec-rails', '~> 3.7.2'

  # To use a debugger
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # gem 'custom_fields', path: '../custom_fields' # for Developers
  # gem 'custom_fields', github: 'locomotivecms/custom_fields', ref: '27f1d62'

  # gem 'locomotivecms_common', path: '../common', require: false
  # gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '257047b', require: false

  # gem 'locomotivecms_steam', path: '../steam', require: false
  gem 'locomotivecms_steam', github: 'locomotivecms/steam', ref: '4e2035c', require: false

  # gem 'locomotive_liquid', path: '../gems/liquid' # for Developers
  # gem 'locomotivecms_solid', path: '../gems/solid' # for Developers

  # gem 'carrierwave-mongoid', git: 'git://github.com/locomotivecms/carrierwave-mongoid.git'
end

group :test do
  gem 'capybara',                 '~> 2.18'
  gem 'selenium-webdriver',       '~> 3.11.0'
  gem 'puma',                     '~> 3.11.3'

  gem 'grape-entity-matchers',    github: 'salsify/grape-entity-matchers', branch: 'grape-entity-exposures'
  gem 'shoulda-matchers',         '~> 3.1.2'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'factory_bot_rails',        '~> 4.8.2'
  gem 'json_spec',                '~> 1.1.4'
  gem 'database_cleaner',         '~> 1.6.2'
  gem 'timecop',                  '~> 0.9.1'
  gem 'email_spec',               '~> 2.1.1'

  gem 'codeclimate-test-reporter',  '~> 1.0.7',  require: false
  gem 'coveralls',                  '~> 0.8.19', require: false
end
