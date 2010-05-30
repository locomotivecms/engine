# Edit this Gemfile to bundle your application"s dependencies.
source "http://gemcutter.org"
source "http://gems.github.com"

gem "rails", "3.0.0.beta3"

gem "liquid"
gem "bson_ext", ">= 1.0.1"
gem "mongo_ext"
gem "mongoid", ">= 2.0.0.beta6" 
gem "mongoid_acts_as_tree", :git => 'git://github.com/evansagge/mongoid_acts_as_tree.git'
gem "warden"
gem "devise", ">= 1.1.rc0"
gem "haml", '>= 3.0.1' #, :git => 'git://github.com/nex3/haml.git'
gem "formtastic", :git => 'git://github.com/justinfrench/formtastic.git', :branch => 'rails3'	
gem "mongoid_acts_as_tree", :git => 'git://github.com/evansagge/mongoid_acts_as_tree.git'
gem "carrierwave", :git => "http://github.com/jnicklas/carrierwave.git"
gem "rmagick"


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