### Pages

Given /^I have a simple page at "([^"]*)" with the body:$/ do |page_slug, page_contents|
  @page = Factory("content page", :slug => page_slug, :body => page_contents, :site => @site)
end

Given /^I have a simple page at "([^"]*)" with the layout "([^"]*)" and the body:$/ do |page_slug, layout_name, page_contents|
  layout = @site.layouts.where(:name => layout_name).first
  raise "Could not find layout: #{layout_name}" unless layout

  @page = Factory("content page", :slug => page_slug, :layout => layout, :body => page_contents, :site => @site)
end

When /^I view the rendered page at "([^"]*)"$/ do |slug|
  visit "http://#{@site.domains.first}/#{slug}"
end

Then /^I should have "(.*)" in the (.*) page (.*)$/ do |content, page_slug, part_slug|
  page = @site.pages.where(:slug => page_slug).first
  raise "Could not find page: #{page_slug}" unless page

  part = page.parts.where(:slug => part_slug).first
  raise "Could not find part: #{part_slug} within page: #{page_slug}" unless part

  part.value.should == content
end

Then /^the rendered output should look like:$/ do |body_contents|
  page.body.should == body_contents
end

Given /^a layout named "([^"]*)" with the body:$/ do |layout_name, layout_body|
  @layout = Factory(:layout, :name => layout_name, :value => layout_body, :site => @site)
end

