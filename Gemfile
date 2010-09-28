# Edit this Gemfile to bundle your application's dependencies.
source :rubygems

# add in all the runtime dependencies

gem "rails", ">= 3.0.0"
gem "locomotive_liquid", ">= 2.1.3"
gem "bson_ext", ">= 1.0.8"
gem "mongoid", :git => 'http://github.com/mongoid/mongoid.git'
gem "mongoid_acts_as_tree", "= 0.1.5"
gem "mongo_session_store", "= 2.0.0.pre"
gem "warden"
gem "devise", "= 1.1.2"
gem "haml", "= 3.0.18"
gem "rmagick", "= 2.12.2"
gem "aws"
gem "mimetype-fu"
gem "formtastic", ">= 1.1.0"
gem "carrierwave", "0.5.0.beta2"
gem "actionmailer-with-request"
gem "heroku"
gem "httparty", ">= 0.6.1"
gem "RedCloth"
gem "inherited_resources", ">= 1.1.2"
gem "custom_fields", :git => "http://github.com/locomotivecms/custom_fields.git"


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