require 'rubygems'
gemfile = File.expand_path('../../../../Gemfile', __FILE__)

# Need to explicitly use syck for yaml. This fixes a problem with the current
# delayed job parsing of YAML
#
# FIXME: I don't expect end users to have to modify their config/boot.rb for an
# app using the locomotiveCMS gem. Perhaps we can remove this when a newer
# delayed job version is released?
#
require 'yaml'
YAML::ENGINE.yamler = 'syck' if defined?(YAML::ENGINE)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
end

$:.unshift File.expand_path('../../../../lib', __FILE__)
