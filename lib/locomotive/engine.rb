puts "...loading Locomotive engine"

require 'rails'
require 'devise'
require 'mongoid'
require 'mongoid_acts_as_tree'
require 'will_paginate'
require 'haml'
require 'liquid'
require 'formtastic'
require 'inherited_resources'
require 'carrierwave'
require 'custom_fields'
require 'mimetype_fu'
require 'actionmailer_with_request'
require 'heroku'
require 'httparty'
require 'redcloth'
#require 'delayed_job_mongoid'
require 'zip/zipfilesystem'
require 'jammit-s3'

$:.unshift File.dirname(__FILE__)

module Locomotive
  class Engine < Rails::Engine

    rake_tasks do
      load "railties/tasks.rake"
    end

    initializer "serving fonts" do |app|
      app.middleware.insert_after Rack::Lock, '::Locomotive::Middlewares::Fonts', :path => %r{^/fonts}
    end

  end
end
