#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load APP_RAKEFILE

# === Locomotive tasks ===
load 'lib/tasks/locomotive.rake'

# === Gems install tasks ===
Bundler::GemHelper.install_tasks

# === Travis
task :travis do
  ["rspec spec", "cucumber -b"].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end

# === RSpec ===
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

# === Cucumber ===
load 'lib/tasks/cucumber.rake'

# === Default task ===
task :default => [:spec, :cucumber]
