# require "rubygems"
# require "ruby-prof"
ENV["RAILS_ENV"] ||= 'test'

require "./" + File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

%w{sites pages layouts}.each do |collection|
  Mongoid.master.collection(collection).drop
end

puts "Starting test..."

site = Site.create :name => 'Benchmark Website', :handle => 'benchmark'

simple = site.pages.create :title => 'Simple', :slug => 'simple', :raw_template => %{
  <html>
    <head></head>
    <body>
      <div class="header"></div>
      <div class="content">
        <div class="sidebar">
          A sidebar here / INDEX sidebar
        </div>
        <div class="body">
          <div class="wrapper">Lorem ipsum</div>
        </div>
      </div>
      <div class="footer"></div>
    </body>
  </html>
}

base = site.pages.create :title => 'Base page', :slug => 'base', :raw_template => %{
  <html>
    <head></head>
    <body>
      <div class="header"></div>
      <div class="content">
        <div class="sidebar">
          {% block sidebar %}My simple sidebar{% endblock %}
        </div>
        <div class="body">
          {% block body %}Just to say hi{% endblock %}
        </div>
      </div>
      <div class="footer"></div>
    </body>
  </html>
}

page_1 = site.pages.create :title => 'Page 1', :slug => 'page_1', :raw_template => %{
  {% extends base %}
  {% block sidebar %}A sidebar here{% endblock %}
  {% block body %}<div class="wrapper">{% block main %}DEFAULT MAIN CONTENT{% endblock %}</div>{% endblock %}
}

page_2 = site.pages.create :title => 'Page 2', :slug => 'page_2', :raw_template => %{
  {% extends page_1 %}
  {% block sidebar %}{{ block.super }} / INDEX sidebar{% endblock %}
  {% block main %}Lorem ipsum{% endblock %}
}

puts "OUTPUT = #{page_2.render(Liquid::Context.new)}"

context = Liquid::Context.new({}, { 'site' => site }, { :site => site })

Benchmark.bm do |bm|
  bm.report("Rendering a simple page 10k times") do
    10000.times do
      Page.where(:title => 'Simple').first.render(context)
    end
  end

  bm.report("Rendering a complex page 10k times") do
    10000.times do
      Page.last.render(context)
    end
  end
end

# # empty page (imac 27'):                                    User        System    Total        Real
# Rendering page 10k times                                    21.390000   1.820000  23.210000   ( 24.120529)

# # empty page (mac mini core 2 duo / 2Go):                   User        System    Total        Real
# Rendering a simple page 10k times                           17.130000   0.420000  17.550000   ( 19.459768)

# # page with inherited template (imac 27'):                  User        System    Total        Real
# Rendering page 10k times                                    85.840000   7.600000  93.440000   ( 97.841248)

# # with optimization (imac 27'):                             User        System    Total        Real
# Rendering page 10k times                                    84.240000   7.280000  91.520000   ( 95.475565)

# # with locomotive liquid (imac 27'):                        User        System    Total        Real
# Rendering page 10k times                                    38.750000   3.050000  41.800000   ( 42.880022)

# # with locomotive liquid (mac mini core 2 duo / 2Go):       User        System    Total        Real
# Rendering a complex page 10k times                          30.840000   0.530000  31.370000   ( 32.847565)


