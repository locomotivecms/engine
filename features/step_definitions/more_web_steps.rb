When /^I follow image link "([^"]*)"$/ do |img_alt|
    find(:xpath, "//img[@alt = '#{img_alt}']/parent::a").click()
end

Then /^I should get a download with the filename "([^\"]*)"$/ do |filename|
  page.response_headers['Content-Disposition'].should include("filename=\"#{filename}\"")
end

When /^I wait until "([^"]*)" is visible$/ do |selector|
  page.has_css?("#{selector}", :visible => true)
end

Then /^"([^"]*)" should( not)? be an option for "([^"]*)"(?: within "([^\"]*)")?$/ do |value, negate, field, selector|
  with_scope(selector) do
    expectation = negate ? :should_not : :should
    field_labeled(field).first(:xpath, ".//option[text() = '#{value}']").send(expectation, be_present)
  end
end