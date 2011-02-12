require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

Locomotive::Application.load_tasks

gemspec = eval(File.read('locomotive_cms.gemspec'))
Rake::GemPackageTask.new(gemspec) do |pkg|
  pkg.gem_spec = gemspec
end

desc "build the gem and release it to rubygems.org"
task :release => :gem do
  sh "gem push pkg/locomotive_cms-#{gemspec.version}.gem"
end

task :default => [:spec, :cucumber]