### Snippets

# helps create a simple snippet with a slug and template
def create_snippet(name, template = nil)
  snippet = @site.snippets.create(:name => name, :template => template)
  snippet.should be_valid
  snippet
end

# creates a snippet

Given /^a snippet named "([^"]*)" with the template:$/ do |name, template|
  @snippet = create_snippet(name, template)
end

# checks to see if a string is in the slug
Then /^I should have "(.*)" in the (.*) snippet/ do |content, snippet_slug|
  snippet = @site.snippets.where(:slug => snippet_slug).first
  raise "Could not find snippet: #{snippet_slug}" unless snippet

  snippet.template.should == content
end

