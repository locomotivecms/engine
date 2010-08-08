# require "rubygems"
# require "ruby-prof"
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

# require File.dirname(__FILE__) + "/../config/application.rb"

# Mongoid.configure do |config|
#   config.master = Mongo::Connection.new.db("locomotive_perf_test")
# end

%w{sites pages layouts}.each do |collection|
  Mongoid.master.collection(collection).drop
end

puts "Starting benchmark..."

site = Site.create :name => 'Benchmark Website', :subdomain => 'benchmark'

layout_with_sidebar = site.layouts.create :name => 'with_sidebar', :value => %{
  <html>
    <head></head>
    <body>
      <div class="header"></div>
      <div class="content">
        <div class="sidebar">
          {% block sidebar %}DEFAULT SIDEBAR CONTENT{% endblock %}
        </div>
        <div class="body">
          {% block body %}DEFAULT BODY CONTENT{% endblock %}
        </div>
      </div>
      <div class="footer"></div>
    </body>
  </html>
}

custom_layout_with_sidebar = site.layouts.create :name => 'custom_with_sidebar', :value => %{
  \{% extends 'with_sidebar' %\}
  \{% block sidebar %\}A sidebar here\{% endblock %\}
  \{% block body %\}<div class="wrapper">\{% block main %\}DEFAULT MAIN CONTENT\{% endblock %\}</div>\{% endblock %\}
}

page = site.pages.create :title => 'Index', :slug => 'index', :layout_template => %{
  \{% extends 'custom_with_sidebar' %\}
  \{% block sidebar %\}\{\{ block.super \}\} / INDEX sidebar\{% endblock %\}
  \{% block main %\}Lorem ipsum\{% endblock %\}
}

context = Liquid::Context.new({}, { 'site' => site }, { :site => site })

puts "====> \n#{page.render(context)}"

Benchmark.bm do |bm|
  bm.report("Rendering page 10k times") do
    10000.times do
      Page.first.render(context)
    end
  end
end

# without liquify (macbook white):                          User     System      Total        Real
# Rendering page 10k times                                  22.650000   6.220000  28.870000 ( 30.294338)
