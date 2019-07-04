begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Locomotive'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

load 'rails/tasks/statistics.rake'

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

# === Travis ===
task :travis do
  puts "Install Yarn packages"
  system('yarn install')

  puts "Precompile assets first to avoid potential time outs"
  system("cd spec/dummy && bundle exec rails assets:precompile && cd ..")

  puts "Starting to run RSpec..."
  system("export DISPLAY=:99.0 && bundle exec rspec spec")
  raise "RSpec failed!" unless $?.exitstatus == 0
end

task default: :spec

