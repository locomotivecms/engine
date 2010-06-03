puts "...Locomotive engine loaded"

require 'liquid'
require 'devise'
require 'carrierwave'
require 'formtastic'
require 'mongoid'
require 'mongoid_acts_as_tree'

require File.dirname(__FILE__) + '/../../vendor/plugins/custom_fields/init.rb'

module Locomotive
  class Engine < Rails::Engine

    initializer "locomotive.add_helpers" do |app|
      path = [*ActionController::Base.helpers_path] << File.dirname(__FILE__) + "/../../app/helpers"
      ActionController::Base.helpers_path = path
    end
        
  end
end