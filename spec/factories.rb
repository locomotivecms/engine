## Site ##
Factory.define :site do |s|
  s.name 'Acme Website'
  s.subdomain 'acme'
  s.created_at Time.now
end

Factory.define "test site", :parent => :site do |s|
  s.name 'Locomotive test website'
  s.subdomain 'test'
  s.after_build do |site_test|
    site_test.memberships.build :account => Account.where(:name => "Admin").first || Factory("admin user"), :admin => true
  end
end

Factory.define "another site", :parent => "test site" do |s|
  s.name "Locomotive test website #2"
  s.subdomain "test2"
end


# Accounts ##
Factory.define :account do |a|
  a.name 'Bart Simpson'
  a.email 'bart@simpson.net'
  a.password 'easyone'
  a.password_confirmation 'easyone'
  a.locale 'en'
end

Factory.define "admin user", :parent => :account do |a|
  a.name "Admin"
  a.email "admin@locomotiveapp.org"
end

Factory.define "frenchy user", :parent => :account do |a|
  a.name "Jean Claude"
  a.email "jean@frenchy.fr"
  a.locale 'fr'
end


## Memberships ##
Factory.define :membership do |m|
  m.admin true
  m.account{ Account.where(:name => "Bart Simpson").first || Factory(:account) }
end


## Pages ##
Factory.define :page do |p|
  p.title 'Home page'
  p.slug 'index'
  p.published true
  p.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


# Factory.define "unpub"

## Liquid templates ##
Factory.define :liquid_template do |t|
  t.name 'Simple one'
  t.slug 'simple_one'
  t.value %{simple liquid template}
  t.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Layouts ##
Factory.define :layout do |l|
  l.name '1 main column + sidebar'
  l.value %{<html>
    <head>
      <title>My website</title>
    </head>
    <body>
      <div id="sidebar">
        \{% block sidebar %\}
        DEFAULT SIDEBAR CONTENT
        \{% endblock %\}
      </div>
      <div id="main">
        \{% block main %\}
          DEFAULT MAIN CONTENT
        \{% endblock %\}
      </div>
    </body>
  </html>}
  l.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end

Factory.define :base_layout, :parent => :layout do |l|
  l.name '1 main column + sidebar'
  l.value %{<html>
    <head>
      <title>My website</title>
    </head>
    <body>
      <div id="sidebar">\{\{ content_for_left_sidebar \}\}</div>
      <div id="main">\{\{ content_for_layout | textile \}\}</div>
    </body>
  </html>}
end


## Snippets ##
Factory.define :snippet do |s|
  s.name 'My website title'
  s.slug 'header'
  s.value %{<title>Acme</title>}
  s.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Theme assets ##
Factory.define :theme_asset do |a|
  a.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Asset collections ##
Factory.define :asset_collection do |s|
  s.name 'Trip to Chicago'
  s.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Content types ##
Factory.define :content_type do |t|
  t.name 'My project'
  t.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end

