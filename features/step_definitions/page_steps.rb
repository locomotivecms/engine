### Pages

Given /^I have a simple page created at "([^"]*)" with the body:$/ do |slug, page_contents|
  @page = Factory(:page, :site => @site, :slug => slug, :body => page_contents)
end

When /^I view the rendered page at "([^"]*)"$/ do |slug|
  visit "/#{slug}"
end

Then /^I should have "(.*)" in the (.*) page (.*)$/ do |content, page_slug, slug|
  page = @site.pages.where(:slug => page_slug).first
  part = page.parts.where(:slug => slug).first
  part.should_not be_nil
  part.value.should == content
end

Then /^the rendered output should look like:$/ do |body_contents|
  page.body.should == body_contents
end
