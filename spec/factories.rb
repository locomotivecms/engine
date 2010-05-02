## Site ##
Factory.define :site do |s|
  s.name 'Acme Website'
  s.subdomain 'acme'
  s.created_at Time.now
end

# Accounts ##
Factory.define :account do |a|
  a.name 'Bart Simpson'
  a.email 'bart@simpson.net'
  a.password 'easyone'
  a.password_confirmation 'easyone'
  a.locale 'en'
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
      <title>Hello world !</title>
    </head>
    <body>
      <div id="main">\{\{ content_for_layout \}\}</div>
      <div id="sidebar">\{\{ content_for_sidebar "Left Sidebar"\}\}</div>
    </body>
  </html>}
end

## Snippets ##
Factory.define :snippet do |s|
  s.association :site, :factory => :site
  s.name 'My website title'
  s.slug 'header'
  s.value %{<title>Acme</title}
end