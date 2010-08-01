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
  m.association :account, :factory => :account
  m.admin true
end


## Pages ##
Factory.define :page do |p|
  p.association :site, :factory => :site
  p.title 'Home page'
  p.slug 'index'
end


## Liquid templates ##
Factory.define :liquid_template do |t|
  t.association :site, :factory => :site
  t.name 'Simple one'
  t.slug 'simple_one'
  t.value %{simple liquid template}
end


## Layouts ##
Factory.define :layout do |l|
  l.association :site, :factory => :site
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
  s.association :site, :factory => :site
  s.name 'My website title'
  s.slug 'header'
  s.value %{<title>Acme</title>}
end


## Theme assets ##
Factory.define :theme_asset do |a|
  a.association :site
end


## Asset collections ##
Factory.define :asset_collection do |s|
  s.association :site, :factory => :site
  s.name 'Trip to Chicago'
end


## Content types ##
Factory.define :content_type do |t|
  t.association :site, :factory => :site
  t.name 'My project'
end

