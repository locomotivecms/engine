# Edit this Gemfile to bundle your application"s dependencies.
source "http://gemcutter.org"
source "http://gems.github.com"

gem "rails", "3.0.0.beta2"

gem "liquid"
gem "bson_ext"
gem "mongo_ext"
gem "mongoid", ">= 2.0.0.beta2" 
gem "warden"
gem "devise", ">= 1.1.rc0"


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
end