Before('@site_up') do
  create_site_and_admin_account
  create_layout_samples
  create_index_page
end

Before('@authenticated') do
  Given %{I am an authenticated user}
end

### Authentication

Given /^I am not authenticated$/ do
  visit('/admin/logout')
end


Given /^I am an authenticated user$/ do
  Given %{I go to login}
  And %{I fill in "account_email" with "admin@locomotiveapp.org"}
  And %{I fill in "account_password" with "easyone"}
  And %{I press "Log in"}
end

Then /^I am redirected to "([^\"]*)"$/ do |url|
  assert [301, 302].include?(@integration_session.status), "Expected status to be 301 or 302, got #{@integration_session.status}"
  location = @integration_session.headers["Location"]
  assert_equal url, location
  visit location
end

### Pages


Then /^I should have "(.*)" in the (.*) page (.*)$/ do |content, page_slug, slug|
  page = @site.pages.where(:slug => page_slug).first
  part = page.parts.where(:slug => slug).first
  part.should_not be_nil
  part.value.should == content
end

## Common

def create_site_and_admin_account
  @site = Factory(:site, :name => 'Locomotive test website', :subdomain => 'test')  
  @admin = Factory(:account, { :name => 'Admin', :email => 'admin@locomotiveapp.org' })
end

def create_layout_samples
  Factory(:layout, :site => @site, :name => 'One column', :value => %{<html>
    <head>
      <title>My website</title>
    </head>
    <body>
      <div id="main">\{\{ content_for_layout \}\}</div>
    </body>
  </html>})
  Factory(:layout, :site => @site)
end

def create_index_page
  Factory(:page, :site => @site, :layout => @site.layouts.last, :parts => [PagePart.new(:slug => 'layout', :name => 'Body', :value => 'Hello world')])
end