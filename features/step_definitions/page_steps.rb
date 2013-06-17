### Pages

# helps create a simple content page (parent: "index") with a slug and template
def create_content_page(slug, template = nil)
  new_content_page(slug, template).tap do |page|
    page.save!.should be_true
  end
  # page = new_content_page(slug, page_contents, template)
  # raise "Invalid page: #{page.errors.full_messages}" unless page.valid?
  # page.should be_valid
  # page.save!
  # page
end

# build page without saving
def new_content_page(slug, template = nil)
  @home = @site.pages.where(slug: 'index').first || FactoryGirl.create(:page)
  title = slug.gsub(/-/, '_').humanize
  @site.pages.new(title: title, slug: slug, parent: @home, published: true, raw_template: template)
end

# creates a page
# Given /^a simple page named "([^"]*)" with the body:$/ do |page_slug, page_contents|
#   @page = create_content_page(page_slug, page_contents)
# end

Given /^a page named "([^"]*)" with the template:$/ do |slug, template|
  @page = create_content_page(slug, template)
end

Given /^a page named "([^"]*)" with id "([^"]*)"$/ do |slug, id|
  @page = new_content_page(slug, '')
  @page.id = Moped::BSON::ObjectId(id)
  @page.save!
end

Given /^a page named "([^"]*)" with id "([^"]*)" and template:$/ do |slug, id, template|
  @page = new_content_page(slug, template)
  @page.id = Moped::BSON::ObjectId(id)
  @page.save!
end

Given(/^a page named "(.*?)" with the handle "(.*?)"$/) do |slug, handle|
  page = new_content_page(slug, '')
  page.handle = handle
  page.save!
end

Given(/^the page named "(.*?)" has the title "(.*?)" in the "(.*?)" locale$/) do |slug, title, locale|
  page = @site.pages.where(slug: slug).first
  ::Mongoid::Fields::I18n.with_locale(locale) do
    page.update_attributes!(title: title, slug: title.permalink)
  end
end

Given /^a templatized page for the "(.*?)" model and with the template:$/ do |model_name, template|
  content_type = Locomotive::ContentType.where(name: model_name).first
  parent = create_content_page(content_type.slug, '')
  @page = @site.pages.new(parent: parent, title: "Template for #{model_name}", published: true,
    templatized: true, target_klass_name: content_type.entries_class_name,
    raw_template: template)
  @page.save!
end

# change the title
When /^I change the page title to "([^"]*)"$/ do |title|
  page.evaluate_script "window.prompt = function() { return '#{title}'; }"
  page.find('h2 a.editable').click
end

# change the template
When /^I change the page template to "([^"]*)"$/ do |template|
  page.evaluate_script "window.application_view.view.model.set({ 'raw_template': '#{template}' })"
end

# update a page
When /^I update the "([^"]*)" page with the template:$/ do |slug, template|
  page = @site.pages.where(slug: slug).first
  page.raw_template = template
  page.save!
end

Given /^I delete the following code "([^"]*)" from the "([^"]*)" page$/ do |code, slug|
  page = @site.pages.where(slug: slug).first
  page.raw_template = page.raw_template.gsub(code, '')
  page.save!
end

Given(/^the page "(.*?)" is unpublished$/) do |slug|
  page = @site.pages.where(slug: slug).first
  page.published = false
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
Then /^I should have "(.*)" in the (.*) page$/ do |content, slug|
  page = @site.pages.where(slug: slug).first
  raise "Could not find page: #{slug}" unless page
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

Then /^updated_at of the (.*) page should respect site's timezone$/ do |slug|
  edited_page = @site.pages.where(slug: slug).first
  t = edited_page.updated_at.in_time_zone(@site.timezone)
  page.source.should =~ /#{t.strftime('%-d %b %H:%M')}/
end


