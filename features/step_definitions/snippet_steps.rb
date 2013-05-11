### Snippets

# helps create a simple snippet with a slug and template
def new_snippet(name, template = nil)
  @site.snippets.new(:name => name, :template => template)
end

def create_snippet(name, template = nil)
  snippet = new_snippet(name, template)
  snippet.save!
  snippet
end

# creates a snippet

Given /^a snippet named "([^"]*)" with the template:$/ do |name, template|
  @snippet = create_snippet(name, template)
end

Given /^a snippet named "([^"]*)" with id "([^"]*)" and template:$/ do |name, id, template|
  @snippet = new_snippet(name, template)
  @snippet.id = Moped::BSON::ObjectId(id)
  @snippet.save!
end

When /^I change the snippet template to "([^"]*)"$/ do |code|
  page.evaluate_script "window.application_view.view.editor.setValue('#{code}')"
end

# checks to see if a string is in the slug
Then /^I should have "(.*)" in the (.*) snippet/ do |content, snippet_slug|
  snippet = @site.snippets.where(:slug => snippet_slug).first
  raise "Could not find snippet: #{snippet_slug}" unless snippet

  snippet.template.should == content
end

