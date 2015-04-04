#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load APP_RAKEFILE

# === LocomotiveCMS tasks ===
load 'lib/tasks/locomotive.rake'

# === Gems install tasks ===
Bundler::GemHelper.install_tasks

# === Travis ===
task :travis do
  puts "Precompile assets first to avoid potential time outs"
  system("bundle exec rake assets:precompile")
  ["rspec spec"].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end

Rake::Task[:default].clear
Rake::Task[:spec].clear

desc "Run all Locomotive specs in spec directory"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.exclude_pattern = 'spec/controllers/api/locomotive/**/*_spec.rb,spec/lib/locomotive/presentable_spec.rb'
end

# === Default task ===
task :default => [:spec]
