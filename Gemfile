source 'http://rubygems.org'

# add in all the runtime dependencies

gem 'rake',                 '0.9.2'

gem 'rails',                '~> 3.1.1'


gem 'devise',               :path => '../gems/devise' # FIXME: git clone git@github.com:locomotivecms/devise.git; git checkout scoped_mailer
# gem 'devise',               '~> 1.4.9'
gem 'cancan',               '~> 1.6.7'

gem 'bson',                 '~> 1.3.1'
gem 'mongo',                '~> 1.3.1'
gem 'bson_ext',             '~> 1.3.1'
gem 'mongoid',              '~> 2.3.3'
gem 'locomotive_mongoid_acts_as_tree', '0.1.5.7', :require => 'mongoid_acts_as_tree', :path => '../gems/acts_as_tree' # TODO: REPLACE IT
gem 'custom_fields',        '~> 1.1.0.rc1', :path => '../gems/custom_fields'
gem 'will_paginate',        '~> 3.0.2'

gem 'haml',                 '~> 3.1.3'
gem 'sass-rails',           '~> 3.1.4'
gem "compass",              :git => 'git://github.com/chriseppstein/compass.git', :branch => 'rails31'
gem 'coffee-script',        '~> 2.2.0'
gem 'uglifier',             '~> 1.0.4'
gem 'jquery-rails',         '~> 1.0.16'
gem 'rails-backbone',       '0.5.4'
gem 'handlebars-rails',     :git => 'git://github.com/yabawock/handlebars-rails.git'

gem 'locomotive_liquid',    '2.2.2', :require => 'liquid'
gem 'formtastic',           '~> 1.2.3' # TODO: UPGRADE IT
gem 'inherited_resources',  '~> 1.3.0'
gem 'cells',                '~> 3.7.0'
gem 'RedCloth',             '~> 4.2.8'
gem 'sanitize',             '~> 2.0.3'
gem 'highline',             '~> 1.6.2'

gem 'rmagick',              '2.12.2', :require => 'RMagick'
gem 'carrierwave-mongoid',  '~> 0.1.3'
gem 'fog',                  '~> 1.0.0'
gem 'dragonfly',            '~> 0.9.8'
gem 'rack-cache',           '~> 1.1', :require => 'rack/cache'
gem 'mimetype-fu',          '~> 0.1.2'
gem 'rubyzip'

gem 'actionmailer-with-request', '~> 0.3.0', :require => 'actionmailer_with_request'
gem 'httparty',             '~> 0.8.1'
gem 'delayed_job',          '~> 2.1.1'
gem 'delayed_job_mongoid',  '~> 1.0.4'
gem 'SystemTimer',          :platforms => :ruby_18



# The rest of the dependencies are for use when in the locomotive dev environment

group :development do
  gem 'unicorn' # Using unicorn_rails instead of webrick (default server)
  gem 'rspec-rails', '2.6.1' # in order to have rspec tasks and generators
  gem 'rspec-cells'
end

group :test, :development do
  gem 'linecache', '0.43', :platforms => :mri_18
  gem 'ruby-debug', :platforms => :mri_18
  gem 'ruby-debug19', :platforms => :mri_19, :require => 'ruby-debug'
  gem 'cucumber-rails'
end

group :test do
  gem 'autotest', :platforms => :mri
  gem 'ZenTest', :platforms => :mri
  gem 'growl-glue'
  gem 'rspec-rails', '2.6.1'
  gem 'factory_girl_rails', '~> 1.1'
  gem 'pickle'
  gem 'xpath', '~> 0.1.4'
  gem 'capybara'
  gem 'database_cleaner'

  gem 'spork', '~> 0.9.0.rc'
  gem 'launchy'
  gem 'mocha', '0.9.12' # :git => 'git://github.com/floehopper/mocha.git'
end

group :production do
  gem 'bushido', '0.0.35'
end

