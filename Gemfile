# Edit this Gemfile to bundle your application's dependencies.
source 'http://rubygems.org'

gem 'rails', '3.0.0'

gem 'liquid', :git => 'git://github.com/locomotivecms/liquid.git', :ref => 'b03cdc289ac36c339545'

gem 'bson_ext', '= 1.0.4'
gem 'mongoid', '2.0.0.beta.17'
gem 'mongoid_acts_as_tree', '0.1.5'
gem 'mongo_session_store', '2.0.0.pre'
gem 'warden'
gem 'devise', '1.1.2' #:git => 'git://github.com/plataformatec/devise.git'
gem 'haml', '3.0.18'
gem 'rmagick', '2.12.2'
gem 'aws'
gem 'mimetype-fu', :require => 'mimetype_fu'
gem 'formtastic-rails3', '1.0.0.beta3', :require => 'formtastic'
gem 'carrierwave', '0.5.0.beta2'
gem 'actionmailer-with-request', :require => 'actionmailer_with_request'
gem 'heroku'
gem 'httparty', '0.6.1'
gem 'RedCloth'
gem 'inherited_resources', '1.1.2'
gem 'custom_fields', :git => 'git://github.com/locomotivecms/custom_fields.git'
gem 'jeweler'

# Development environment
group :development do
  # Using mongrel instead of webrick (default server)
  gem 'mongrel'
  gem 'cgi_multipart_eof_fix'
  gem 'fastthread'
end

group :test, :development do
  gem 'ruby-debug19'
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