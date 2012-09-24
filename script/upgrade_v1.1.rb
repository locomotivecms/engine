#!/usr/bin/env ruby
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

# ================ GLOBAL VARIABLES ==============

$database_name      = 'locomotive_engine_dev'
$database_host      = 'localhost'
$database_port      = '27017'
# $database_username  = '<your username>'
# $database_password  = '<your password>'

$default_locale     = 'en'
$locale_exceptions  = {}

# ================ MONGODB ==============

require 'mongoid'

Mongoid.configure do |config|
  db = config.master = Mongo::Connection.new($database_host, $database_port).db($database_name)
  if $database_username && $database_password
    db.authenticate($database_username, $database_password)
  end
end

db = Mongoid.config.master

def get_locale(site_id)
  $locale_exceptions[site_id.to_s] || $default_locale
end

# locomotive_pages

# localize redirect_url
collection = db.collections.detect { |c| c.name == 'locomotive_pages' }
collection.find.each do |page|
  next unless page['redirect_url'].is_a?(String)

  locale = get_locale(page['site_id'])

  collection.update({ '_id' => page['_id'] }, { '$set' => { 'redirect_url' => { locale => page['redirect_url'] } } })
end

# Update Norwegian locale from 'no' to 'nb'
collection = db.collections.detect { |c| c.name == 'locomotive_accounts' }
collection.update({ 'locale' => 'no' }, { '$set' => { 'locale' => 'nb' }}, { :multi => true })