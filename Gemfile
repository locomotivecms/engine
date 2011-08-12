source :rubygems

# add in all the runtime dependencies

gem 'rake', '0.9.2'

gem 'rails', '3.0.9'

gem 'warden'
gem 'devise', '1.3.4'
gem 'devise_bushido_authenticatable', '1.0.0.alpha10', :require => 'devise_cas_authenticatable'

gem 'mongoid', '~> 2.0.2'
gem 'bson_ext', '~> 1.3.0'
gem 'locomotive_mongoid_acts_as_tree', '0.1.5.7', :require => 'mongoid_acts_as_tree'
gem 'will_paginate'

gem 'haml', '3.1.2'
gem 'sass', '3.1.2'
gem 'locomotive_liquid', '2.2.2', :require => 'liquid'
gem 'formtastic', '~> 1.2.3'
gem 'inherited_resources', '~> 1.1.2'

gem 'rmagick', '2.12.2', :require => 'RMagick'
gem 'carrierwave', '~> 0.5.5'
gem 'dragonfly',  '~> 0.9.1'
gem 'rack-cache', :require => 'rack/cache'

gem 'custom_fields', '1.0.0.beta.22'
gem 'cancan'
gem 'fog', '0.8.2'
gem 'mimetype-fu'
gem 'actionmailer-with-request', :require => 'actionmailer_with_request'
gem 'heroku', '1.19.1'
gem 'httparty', '>= 0.6.1'
gem 'RedCloth', '4.2.7'
gem 'delayed_job', '2.1.4'
gem 'delayed_job_mongoid', '1.0.2'
gem 'rubyzip'
gem 'locomotive_jammit-s3', :require => 'jammit-s3'
gem 'SystemTimer', :platforms => :ruby_18
gem 'cells'

# The rest of the dependencies are for use when in the locomotive dev environment

group :development do
  gem 'unicorn' # Using unicorn_rails instead of webrick (default server)

  gem 'rspec-rails', '2.6.1' # in order to have rspec tasks and generators

  gem 'rspec-cells'
end

group :test, :development do
  gem 'linecache', '0.43', :platforms => :mri_18
  gem 'ruby-debug', :platforms => :mri_18
  gem 'ruby-debug19', :platforms => :mri_19

  gem 'bushido_stub', '0.0.3'

  gem 'cucumber-rails', '1.0.2'
end

group :test do
  gem 'autotest'
  gem 'ZenTest'
  gem 'growl-glue'
  gem 'rspec-rails', '2.6.1'
  gem 'factory_girl_rails'
  gem 'pickle'
  gem 'xpath', '~> 0.1.4'
  gem 'capybara'
  gem 'database_cleaner'

  gem 'spork'
  gem 'launchy'
  gem 'mocha', :git => 'git://github.com/floehopper/mocha.git'
end

group :production do
  gem 'bushido', '0.0.35'
end

