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
    gem.authors = ['Didier Lafforgue']
    gem.email = ['didier@nocoffee.fr']
    gem.date = Date.today
    gem.description = "a brand new CMS system with super sexy UI and cool features (alpha version for now)"
    gem.homepage = %q{http://www.locomotiveapp.org}
    gem.files = Dir[
      "Gemfile", 
      "{app}/**/*", 
      "{config}/**/*",
      "{lib}/**/*",
      "{public}/stylesheets/admin/**/*", "{public}/javascripts/admin/**/*", "{public}/images/admin/**/*", 
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
  Jeweler::GemcutterTasks.new
rescue
  puts "Jeweler or one of its dependencies is not installed."
end

