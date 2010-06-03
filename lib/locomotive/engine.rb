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
    
    # initializer "locomotive.require_dependencies", :after => :initialize_dependency_mechanism do
    #   require 'bundler'
    #   gemfile = Bundler::Definition.from_gemfile(root.join('Gemfile'))
    #   
    #   specs = gemfile.dependencies.select do |d|
    #     !%w{jeweler rails}.include?(d.name) and (d.groups & [:default, :production]).any?
    #   end
    #   specs.collect { |s| s.autorequire || [s.name] }.flatten.each do |r|
    #     puts "requiring #{r}"
    #     require r
    #   end
    #   
    #   # gemify it soon
    #   require File.dirname(__FILE__) + '/../../vendor/plugins/custom_fields/init.rb'      
    # end
        
  end
end