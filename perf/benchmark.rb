# require "rubygems"
# require "ruby-prof"
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

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

page = site.pages.create :title => 'Benchmark', :slug => 'benchmark', :layout_template => %{
  \{% extends 'custom_with_sidebar' %\}
  \{% block sidebar %\}\{\{ block.super \}\} / INDEX sidebar\{% endblock %\}
  \{% block main %\}Lorem ipsum\{% endblock %\}
}

context = Liquid::Context.new({}, { 'site' => site }, { :site => site })

puts "====> OUTPUT \n#{page.render(context)}"

Benchmark.bm do |bm|
  bm.report("Rendering page 10k times") do
    10000.times do
      Page.last.render(context)
    end
  end
end

# # empty page (imac 27'):                                    User        System    Total        Real
# # Rendering page 10k times                                  13.390000   1.700000  15.090000   ( 15.654966)

# # page with inherited template (imac 27'):                  User        System    Total        Real
# Rendering page 10k times                                    85.840000   7.600000  93.440000   ( 97.841248)

# # with optimization (imac 27'):                             User        System    Total        Real
# Rendering page 10k times                                    84.240000   7.280000  91.520000 ( 95.475565)
