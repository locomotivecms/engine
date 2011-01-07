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


