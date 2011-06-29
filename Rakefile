require File.expand_path('../config/application', __FILE__)

require 'rubygems'

require 'rake'
require 'rdoc/task'
require 'rubygems/package_task'

Locomotive::Application.load_tasks

gemspec = eval(File.read('locomotive_cms.gemspec'))
Gem::PackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc 'build the gem and release it to rubygems.org'
task :release => :gem do
  sh "gem push pkg/custom_fields-#{gemspec.version}.gem"
end

task :default => [:spec, :cucumber]