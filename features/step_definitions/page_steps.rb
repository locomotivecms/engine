### Pages

# helps create a simple content page (parent: "index") with a slug, contents, and template
def create_content_page(page_slug, page_contents, template = nil)
  page = new_content_page(page_slug, page_contents, template)
  page.should be_valid
  page.save!
  page
end

# build page without saving
def new_content_page(page_slug, page_contents, template = nil)
  @home = @site.pages.where(:slug => "index").first || FactoryGirl.create(:page)
  page = @site.pages.new(:slug => page_slug, :body => page_contents, :parent => @home, :title => "some title", :published => true, :raw_template => template)
  page
end

# creates a page
Given /^a simple page named "([^"]*)" with the body:$/ do |page_slug, page_contents|
  @page = create_content_page(page_slug, page_contents)
end

Given /^a page named "([^"]*)" with the template:$/ do |page_slug, template|
  @page = create_content_page(page_slug, '', template)
end

Given /^a page named "([^"]*)" with id "([^"]*)"$/ do |page_slug, id|
  @page = new_content_page(page_slug, '')
  @page.id = BSON::ObjectId(id)
  @page.save!
end

# change the title
When /^I change the page title to "([^"]*)"$/ do |page_title|
  page.evaluate_script "window.prompt = function() { return '#{page_title}'; }"
  page.find('h2 a.editable').click
end

# change the template
When /^I change the page template to "([^"]*)"$/ do |page_template|
  page.evaluate_script "window.application_view.view.model.set({ 'raw_template': '#{page_template}' })"
end

# update a page
When /^I update the "([^"]*)" page with the template:$/ do |page_slug, template|
  page = @site.pages.where(:slug => page_slug).first
  page.raw_template = template
  page.save!
end

Given /^I delete the following code "([^"]*)" from the "([^"]*)" page$/ do |code, page_slug|
  page = @site.pages.where(:slug => page_slug).first
  page.raw_template = page.raw_template.gsub(code, '')
  page.save!
end

# try to render a page by slug
When /^I view the rendered page at "([^"]*)"$/ do |path|
  # If we're running poltergeist then we need to use a different port
  if Capybara.current_driver == :poltergeist
    visit "http://#{@site.domains.first}:#{Capybara.server_port}#{path}"
  else
    visit "http://#{@site.domains.first}#{path}"
  end
end

# checks to see if a string is in the slug
Then /^I should have "(.*)" in the (.*) page$/ do |content, page_slug|
  page = @site.pages.where(:slug => page_slug).first
  raise "Could not find page: #{page_slug}" unless page
  page.raw_template.should == content
end

# checks if the rendered body matches a string
Then /^the rendered output should look like:$/ do |body_contents|
  # page.source.should == body_contents
  page.source.index(body_contents).should_not be_nil
end

Then /^I should see delete page buttons$/ do
  page.has_css?("ul#pages-list li .more a.remove").should be_true
end

Then /^I should not see delete page buttons$/ do
  page.has_css?("ul#pages-list li .more a.remove").should be_false
end


