# Edit this Gemfile to bundle your application"s dependencies.
source "http://gemcutter.org"
source "http://gems.github.com"

gem "rails", "3.0.0.beta3"

gem "liquid"
gem "bson_ext", ">= 1.0.1"
gem "mongo_ext"
gem "mongoid", ">= 2.0.0.beta6" 
gem "mongoid_acts_as_tree", ">= 0.1.2"
gem "warden"
gem "devise", ">= 1.1.rc0"
gem "haml", ">= 3.0.1"
gem "rmagick", "2.12.2"
gem "aws"
gem "jeweler"
gem "mimetype-fu", :require => "mimetype_fu"
gem "formtastic-rails3", :require => "formtastic"
gem "carrierwave-rails3", :require => "carrierwave"

# Development environment
group :development do
  # Using mongrel instead of webrick (default server)
  gem "mongrel"
  gem "cgi_multipart_eof_fix"
  gem "fastthread"
  gem "mongrel_experimental"
end

group :test do
	gem 'rspec-rails', '>= 2.0.0.beta.5'
	gem 'factory_girl', :git => 'git://github.com/thoughtbot/factory_girl.git', :branch => 'rails3'	
	gem 'capybara', :git => 'git://github.com/jnicklas/capybara.git'
	gem 'cucumber', '0.7.2'    
	gem 'cucumber-rails'
	gem 'spork'
	gem 'launchy'
	gem 'mocha', :git => 'git://github.com/floehopper/mocha.git'	
end