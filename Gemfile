# Edit this Gemfile to bundle your application's dependencies.
source 'http://rubygems.org'

gem 'rails', '3.0.0'

gem 'locomotive_liquid', '2.2.2', :require => 'liquid'

gem 'bson_ext', '1.1'
gem 'mongoid', '2.0.0.beta.19'
gem 'locomotive_mongoid_acts_as_tree', '0.1.5.1', :require => 'mongoid_acts_as_tree'
gem 'mongo_session_store', '2.0.0'
gem 'warden'
gem 'devise', '1.1.2'
gem 'haml', '3.0.18'
gem 'rmagick', '2.12.2'
gem 'aws'
gem 'mimetype-fu', :require => 'mimetype_fu'
gem 'formtastic-rails3', '1.0.0.beta3', :require => 'formtastic'
gem 'locomotive_carrierwave', :require => 'carrierwave'
gem 'actionmailer-with-request', :require => 'actionmailer_with_request'
gem 'heroku'
gem 'httparty', '0.6.1'
gem 'RedCloth'
gem 'inherited_resources', '1.1.2'
gem 'custom_fields', '1.0.0.beta'
gem 'jeweler'
gem 'delayed_job', '2.1.0.pre2'
gem 'delayed_job_mongoid', '1.0.0.rc'
gem 'rubyzip'

# Development environment
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
  gem 'rspec-rails', '2.0.0.beta.19'
  gem 'factory_girl_rails'
  gem 'pickle', :git => 'http://github.com/ianwhite/pickle.git'
  gem 'pickle-mongoid'
  gem 'capybara'

  # would be nice..
  # gem 'capybara-envjs'

  gem 'database_cleaner'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'spork'
  gem 'launchy'
  gem 'mocha', :git => 'git://github.com/floehopper/mocha.git'
end