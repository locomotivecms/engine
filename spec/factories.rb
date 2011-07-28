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
    site_test.memberships.build :account => Account.where(:name => "Admin").first || Factory("admin user"), :role => 'admin'
  end
end

Factory.define "another site", :parent => "test site" do |s|
  s.name "Locomotive test website #2"
  s.subdomain "test2"
end

Factory.define "existing site", :parent => "site" do |s|
  s.name "Locomotive site with existing models"
  s.subdomain "models"
  s.after_build do |site_with_models|
    site_with_models.content_types.build(
      :slug => 'projects', 
      :name => 'Existing name', 
      :description => 'Existing description',
      :order_by => 'created_at')
  end
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

Factory.define "brazillian user", :parent => :account do |a|
  a.name "Jose Carlos"
  a.email "jose@carlos.com.br"
  a.locale 'pt-BR'
end

Factory.define "italian user", :parent => :account do |a|
  a.name "Paolo Rossi"
  a.email "paolo@paolo-rossi.it"
  a.locale 'it'
end


## Memberships ##
Factory.define :membership do |m|
  m.role 'admin'
  m.account { Account.where(:name => "Bart Simpson").first || Factory('admin user') }
end

Factory.define :admin, :parent => :membership do |m|
  m.role 'admin'
  m.account { Factory('admin user', :locale => 'en') }
end

Factory.define :designer, :parent => :membership do |m|
  m.role 'designer'
  m.account { Factory('frenchy user', :locale => 'en') }
end

Factory.define :author, :parent => :membership do |m|
  m.role 'author'
  m.account { Factory('brazillian user', :locale => 'en') }
end


## Pages ##
Factory.define :page do |p|
  p.title 'Home page'
  p.slug 'index'
  p.published true
  p.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Snippets ##
Factory.define :snippet do |s|
  s.name 'My website title'
  s.slug 'header'
  s.template %{<title>Acme</title>}
  s.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Assets ##
Factory.define :asset do |a|
  a.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Theme assets ##
Factory.define :theme_asset do |a|
  a.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Content types ##
Factory.define :content_type do |t|
  t.name 'My project'
  t.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end

