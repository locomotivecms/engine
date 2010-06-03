# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Rails::Application.load_tasks

begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "locomotive_cms"
    gem.summary = "Locomotive cms engine"
    gem.files = Dir["Gemfile", "{lib}/**/*", "{app}/**/*", "{config}/**/*", 
      "{public}/stylesheets/**/*", "{public}/javascripts/**/*", "{public}/images/**/*", 
      "{vendor}/**/*"]
    # other fields that would normally go in your gemspec
    # like authors, email and has_rdoc can also be included here
    bundle = Bundler::Definition.from_gemfile('Gemfile')
    bundle.dependencies.each do |dep|
      if dep.groups.include?(:default)
        gem.add_dependency(dep.name, dep.requirement.to_s)
      end
    end    
  end
rescue
  puts "Jeweler or one of its dependencies is not installed."
end

