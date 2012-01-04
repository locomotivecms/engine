require 'rubygems'

# Need to explicitly use syck for yaml
#require 'yaml'
#YAML::ENGINE.yamler = 'syck' if defined?(YAML::ENGINE)

# Set up gems listed in the Gemfile.
if File.exist?(File.expand_path('../../Gemfile', __FILE__))
  require 'bundler'
  Bundler.setup
end
