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

When /^I type the content "([^"]*)" into the first editable field$/ do |content|
  page.execute_script %{
    $(document).ready(function() {
      editable = GENTICS.Aloha.editables[0];
      editable.obj.text('#{content}');
      editable.blur();
    });
  }
end

