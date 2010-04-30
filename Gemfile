# Edit this Gemfile to bundle your application"s dependencies.
source "http://gemcutter.org"
source "http://gems.github.com"

gem "rails", "3.0.0.beta3"

gem "liquid"
gem "bson_ext", '0.20.1'
gem "mongo_ext"
gem "mongoid", ">= 2.0.0.beta2" 
gem "warden"
gem "devise", ">= 1.1.rc0"
gem "haml", '>= 3.0.0.beta.2', :git => 'git://github.com/nex3/haml.git'
gem "formtastic", :git => 'git://github.com/justinfrench/formtastic.git', :branch => 'rails3'	
gem "mongoid_acts_as_tree", :git => 'git://github.com/evansagge/mongoid_acts_as_tree.git'


# Development environment
group :development do
	# Using mongrel instead of webrick (default server)
	# gem "mongrel"
	# gem "cgi_multipart_eof_fix"
	# gem "fastthread"
	# gem "mongrel_experimental"	
end

group :test do
	gem 'rspec-rails', '>= 2.0.0.beta.5'
	gem 'factory_girl', :git => 'git://github.com/thoughtbot/factory_girl.git', :branch => 'rails3'	
	gem 'capybara', :git => 'git://github.com/jnicklas/capybara.git'
	gem 'cucumber-rails', :git => 'git://github.com/aslakhellesoy/cucumber-rails.git'	
end