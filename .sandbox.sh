#!/bin/sh
# Used in the sandbox rake task in Rakefile

# Prepare outside engine directory
CURRENT_DIR=`pwd`
rm -rf /tmp/sandbox
mkdir /tmp/sandbox
cd /tmp/sandbox

# Initialize sandbox application
if [ ! -d "/tmp/sandbox" ]; then
  echo 'sandbox rails application failed'
  exit 1
fi

cat <<RUBY >> Gemfile
source 'https://rubygems.org'

gem 'rails', '~> 4.2.0'
RUBY

bundle install --gemfile Gemfile
bundle exec rails new . --skip-active-record --skip-test-unit --skip-javascript --skip-bundle --force

cat <<RUBY >> Gemfile
gem 'custom_fields', github: 'locomotivecms/custom_fields', ref: '15cceb66ed'
gem "locomotive_cms", path: "$CURRENT_DIR", :require => "locomotive/engine"
gem 'formtastic'
gem 'compass'
gem 'compass-rails'
gem 'coffee-rails'
gem 'therubyracer'
gem 'unicorn'
RUBY

bundle install --gemfile Gemfile
RAILS_ENV=development bundle exec rails g locomotive:install

cat <<RUBY > config/initializers/carrierwave.rb
CarrierWave.configure do |config|
  config.cache_dir = File.join(Rails.root, 'tmp', 'uploads')
  config.storage = :file
  config.root = File.join(Rails.root, 'public')
end
RUBY

# Replace generated mongo config
if [ -f "$CURRENT_DIR/config/mongoid.yml" ]; then
  echo 'Copy prepared mongoid config to target directory'
  cp $CURRENT_DIR/config/mongoid.yml /tmp/sandbox/mongoid.yml
fi
sed -i '/identity_map_enabled/d' ./config/mongoid.yml

bundle exec rake assets:precompile
