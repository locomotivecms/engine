Given /^a simple page named "([^"]*)" with the body:$/ do |page_slug, page_contents|
  @page = create_content_page(page_slug, page_contents)
end

# modify an editable element
Given /^the editable element "([^"]*)" in the "([^"]*)" page with the content "([^"]*)"$/ do |slug, page_slug, content|
  page = @site.pages.where(:slug => page_slug).first
  page.find_editable_element(nil, slug).content = content
  page.save!
end

# modify an editable element
Given /^the editable element "([^"]*)" for the "([^"]*)" block in the "([^"]*)" page with the content "([^"]*)"$/ do |slug, block, page_slug, content|
  page = @site.pages.where(:slug => page_slug).first
  page.find_editable_element(block, slug).content = content
  page.save!
end