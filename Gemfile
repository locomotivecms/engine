# Edit this Gemfile to bundle your application's dependencies.
source :rubygems

# add in all the runtime dependencies
gemspec

# The rest of the dependencies are for use when in the locomotive dev environment

group :development do
  # Using mongrel instead of webrick (default server)
  gem 'mongrel'
  gem 'cgi_multipart_eof_fix'
  gem 'fastthread'
end

group :test, :development do
  gem 'ruby-debug'
end

group :test do
  gem 'autotest'
  gem 'growl-glue'
  gem 'rspec-rails', '>= 2.0.0.beta.18'
  gem 'factory_girl_rails'
  gem 'pickle', :git => 'http://github.com/ianwhite/pickle.git'
  gem 'capybara'

  gem 'database_cleaner'
  gem 'cucumber', "0.8.5"
  gem 'cucumber-rails'
  gem 'spork'
  gem 'launchy'
  gem 'mocha', :git => 'git://github.com/floehopper/mocha.git'
end