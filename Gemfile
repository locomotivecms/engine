source 'http://rubygems.org'

# add in all the runtime dependencies

gem 'rake',                     '0.9.2'

gem 'rails',                    '~> 3.1.3'

gem 'devise',                   '~> 1.5.3'
gem 'cancan',                   '~> 1.6.7'

gem 'mongo',                    '~> 1.5.2'
gem 'bson_ext',                 '~> 1.5.2'
gem 'mongoid',                  '~> 2.4.0'
gem 'locomotive_mongoid_acts_as_tree', '~> 0.1.5.8'
# gem 'custom_fields',            :path => '../gems/custom_fields' # DEV
gem 'custom_fields',          :git => 'git://github.com/locomotivecms/custom_fields.git', :ref => '472101ade7b4815ec977ee121442cfe28f4db285'
gem 'kaminari'

gem 'haml',                     '~> 3.1.3'
gem 'sass-rails',               '~> 3.1.4'
gem 'coffee-script',            '~> 2.2.0'
gem 'uglifier',                 '~> 1.0.4'
gem 'compass',                  '~> 0.12.alpha.4'
gem 'jquery-rails',             '~> 1.0.16'
gem 'rails-backbone',           '0.5.4'
gem 'codemirror-rails'
gem 'locomotive-tinymce-rails', '~> 3.4.7'
gem 'locomotive-aloha-rails',   '~> 0.20.1'
gem 'flash_cookie_session',     '~> 1.1.1'

gem 'locomotive_liquid',        '2.2.2', :require => 'liquid'
gem 'formtastic',               '~> 2.0.2'
gem 'responders',               '~> 0.6.4'
gem 'cells',                    '~> 3.7.1'
gem 'RedCloth',                 '~> 4.2.8'
gem 'sanitize',                 '~> 2.0.3'
gem 'highline',                 '~> 1.6.2'

gem 'rmagick',                  '2.12.2', :require => 'RMagick'
gem 'carrierwave-mongoid',      '~> 0.1.3'
gem 'fog',                      '~> 1.0.0'
gem 'dragonfly',                '~> 0.9.8'
gem 'rack-cache',               '~> 1.1', :require => 'rack/cache'
gem 'mimetype-fu',              '~> 0.1.2'
gem 'rubyzip'
gem 'actionmailer-with-request',  '~> 0.3.0', :require => 'actionmailer_with_request'
gem 'httparty',                   '~> 0.8.1'
gem 'delayed_job_mongoid',        '~> 1.0.8'
gem 'SystemTimer',                :platforms => :ruby_18

# The rest of the dependencies are for use when in the locomotive dev environment

group :development do
  gem 'unicorn' # Using unicorn_rails instead of webrick (default server)
  gem 'rspec-rails', '2.6.1' # in order to have rspec tasks and generators
  gem 'rspec-cells'
end

group :test do
  gem 'cucumber-rails'
  gem 'autotest', :platforms => :mri
  gem 'ZenTest', :platforms => :mri
  gem 'growl-glue'
  gem 'rspec-rails', '2.6.1'
  gem 'factory_girl_rails', '~> 1.3.0'
  gem 'pickle'
  gem 'xpath', '~> 0.1.4'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'shoulda-matchers'

  gem 'launchy'
  gem 'mocha', '0.9.12' # :git => 'git://github.com/floehopper/mocha.git'
end

group :production do
  gem 'bushido', '0.0.35'
end
