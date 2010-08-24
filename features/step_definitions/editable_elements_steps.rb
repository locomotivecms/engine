Given /^a simple page named "([^"]*)" with the body:$/ do |page_slug, page_contents|
  @page = create_content_page(page_slug, page_contents)
end

# modify an editable element
Given /^the editable element "([^"]*)" with the content "([^"]*)" in the "([^"]*)" page$/ do |slug, content, page_slug|
  page = @site.pages.where(:slug => page_slug).first
  page.find_editable_element(nil, slug).content = content
  page.save!
end