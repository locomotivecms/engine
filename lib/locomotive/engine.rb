puts "...loading Locomotive engine"

require 'rails'
require 'heroku'
require 'inherited_resources'
require 'mimetype_fu'
require 'liquid'
require 'devise'
require 'carrierwave'
require 'formtastic'
require 'mongoid'
require 'mongoid_acts_as_tree'
require 'httparty'
require 'redcloth'
require 'actionmailer_with_request'
require 'zip/zipfilesystem'
require 'custom_fields'
require 'delayed_job_mongoid'
require 'will_paginate'

$:.unshift File.dirname(__FILE__)

module Locomotive
  class Engine < Rails::Engine

    rake_tasks do
      load "railties/tasks.rake"
    end

  end
end
