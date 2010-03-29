# Edit this Gemfile to bundle your application"s dependencies.
source "http://gemcutter.org"

gem "rails", "3.0.0.beta"

gem "liquid"
gem "mongo_ext"
gem "mongo_mapper"

# Using mongrel instead of webrick (default server)
gem "mongrel"
gem "cgi_multipart_eof_fix"
gem "fastthread"
gem "mongrel_experimental"

# Test environment
group :test do
	gem "rspec"
	gem "rspec-rails"
	gem "factory_girl", :git => "git://github.com/szimek/factory_girl.git", :branch => "rails3"	
	gem "shoulda", :require => nil
	gem "remarkable_rails"
  gem "webrat"
	gem "cucumber"
end


## Bundle edge rails:
# gem "rails", :git => "git://github.com/rails/rails.git"

# ActiveRecord requires a database adapter. By default,
# Rails has selected sqlite3.
# gem "sqlite3-ruby", :require => "sqlite3"

## Bundle the gems you use:
# gem "bj"
# gem "hpricot", "0.6"
# gem "sqlite3-ruby", :require => "sqlite3"
# gem "aws-s3", :require => "aws/s3"

## Bundle gems used only in certain environments:
# gem "rspec", :group => :test
