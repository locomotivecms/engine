### Pages

# helps create a simple content page (parent: "index") with a slug, contents, and layout
def create_content_page(page_slug, page_contents, layout = nil, template = nil)
  @home = @site.pages.where(:slug => "index").first || Factory(:page)
  page = @site.pages.create(:slug => page_slug, :body => page_contents, :layout => layout, :parent => @home, :title => "some title", :published => true, :layout_template => template)
  page.should be_valid
  page
end

# creates a page
Given /^a simple page named "([^"]*)" with the body:$/ do |page_slug, page_contents|
  @page = create_content_page(page_slug, page_contents)
end

# creates a page (that has a layout)
Given /^a page named "([^"]*)" with the layout "([^"]*)" and the body:$/ do |page_slug, layout_name, page_contents|
  layout = @site.layouts.where(:name => layout_name).first
  raise "Could not find layout: #{layout_name}" unless layout

  @page = create_content_page(page_slug, page_contents, layout)
end

Given /^a page named "([^"]*)" with the template:$/ do |page_slug, template|
  @page = create_content_page(page_slug, '', nil, template)
end

# creates a layout
Given /^a layout named "([^"]*)" with the source:$/ do |layout_name, layout_body|
  @layout = Factory(:layout, :name => layout_name, :value => layout_body, :site => @site)
end

# creates a part within a page
Given /^the page named "([^"]*)" has the part "([^"]*)" with the content:$/ do |page_slug, part_slug, part_contents|
  page = @site.pages.where(:slug => page_slug).first
  raise "Could not find page: #{page_slug}" unless page

  # find or crate page part
  part = page.parts.where(:slug => part_slug).first
  unless part
    part = page.parts.build(:name => part_slug.titleize, :slug => part_slug)
  end

  # set part value
  part.value = part_contents
  part.should be_valid

  # save page with embedded part
  page.save
end

# try to render a page by slug
When /^I view the rendered page at "([^"]*)"$/ do |path|
  visit "http://#{@site.domains.first}#{path}"
end

# checks to see if a string is in the slug
Then /^I should have "(.*)" in the (.*) page (.*)$/ do |content, page_slug, part_slug|
  page = @site.pages.where(:slug => page_slug).first
  raise "Could not find page: #{page_slug}" unless page

  part = page.parts.where(:slug => part_slug).first
  raise "Could not find part: #{part_slug} within page: #{page_slug}" unless part

  part.value.should == content
end

# checks if the rendered body matches a string
Then /^the rendered output should look like:$/ do |body_contents|
  page.body.should == body_contents
end


