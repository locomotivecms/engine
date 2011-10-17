require File.expand_path('../config/application', __FILE__)

require 'rubygems'

require 'rake/dsl_definition'
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

# only for running the tests suite in the order observed in *nix systems
task :spec_nix do
  files = %w(
    lib/core_ext_spec.rb
    lib/locomotive/routing/site_dispatcher_spec.rb
    lib/locomotive/bushido_spec.rb
    lib/locomotive/render_spec.rb
    lib/locomotive/httparty/patches_spec.rb
    lib/locomotive/httparty/webservice_spec.rb
    lib/locomotive/configuration_spec.rb
    lib/locomotive/liquid/tags/consume_spec.rb
    lib/locomotive/liquid/tags/with_scope_spec.rb
    lib/locomotive/liquid/tags/nav_spec.rb
    lib/locomotive/liquid/tags/editable/content_spec.rb
    lib/locomotive/liquid/tags/editable/short_text_spec.rb
    lib/locomotive/liquid/tags/seo_spec.rb
    lib/locomotive/liquid/tags/paginate_spec.rb
    lib/locomotive/liquid/drops/content_spec.rb
    lib/locomotive/liquid/drops/contents_spec.rb
    lib/locomotive/liquid/drops/page_spec.rb
    lib/locomotive/liquid/drops/site_spec.rb
    lib/locomotive/liquid/filters/resize_spec.rb
    lib/locomotive/liquid/filters/html_spec.rb
    lib/locomotive/liquid/filters/date_spec.rb
    lib/locomotive/liquid/filters/text_spec.rb
    lib/locomotive/liquid/filters/misc_spec.rb
    lib/locomotive/heroku_spec.rb
    lib/locomotive/import_spec.rb
    lib/locomotive/export_spec.rb
    models/content_instance_spec.rb
    models/editable_element_spec.rb
    models/account_spec.rb
    models/content_type_spec.rb
    models/snippet_spec.rb
    models/ability_spec.rb
    models/membership_spec.rb
    models/page_spec.rb
    models/asset_spec.rb
    models/theme_asset_spec.rb
    models/site_spec.rb
    cells/admin/main_menu_cell_spec.rb
    cells/admin/global_actions_spec.rb
    cells/admin/settings_menu_cell_spec.rb
    requests/seo_trailing_slash_spec.rb
  ).collect { |f| File.join('spec', f) }.join(' ')

  sh "bundle exec rspec #{files}"
end

task :travis do
  ["rspec spec", "cucumber -b"].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end
