puts "...Locomotive engine loaded"

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

module Locomotive
  class Engine < Rails::Engine

  end
end
