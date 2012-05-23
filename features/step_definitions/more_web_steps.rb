When /^I follow image link "([^"]*)"$/ do |img_alt|
  find(:xpath, "//img[@alt = '#{img_alt}']/parent::a").click()
end

Then /^I should get a download with the filename "([^\"]*)"$/ do |filename|
  page.response_headers['Content-Disposition'].should include("filename=\"#{filename}\"")
end

When /^I wait until "([^"]*)" is visible$/ do |selector|
  page.has_css?("#{selector}", :visible => true)
end

When /^I wait until ([^"]*) is visible$/ do |locator|
  page.has_css?(selector_for(locator), :visible => true)
end

When /^I sync my form with my backbone model because of Firefox$/ do
  page.execute_script("$(':input').trigger('change')")
end

Then /^"([^"]*)" should not be visible$/ do |text|
  begin
    assert page.find(text).visible? != true
  rescue Capybara::ElementNotFound
  end
end

Then /^"([^"]*)" should( not)? be an option for "([^"]*)"(?: within "([^\"]*)")?$/ do |value, negate, field, selector|
  with_scope(selector) do
    expectation = negate ? :should_not : :should
    field_labeled(field).first(:xpath, ".//option[text() = '#{value}']").send(expectation, be_present)
  end
end

Then /^"([^"]*)" should be selected for "([^"]*)"$/ do |value, field|
  assert page.has_xpath?("//select[@name='#{field}' and option[@selected and contains(text(), '#{value}')]]")
end

When /^I reload the page$/ do
  visit current_path
end

Given /^I enable the CSRF protection for public submission requests$/ do
  Locomotive.config.csrf_protection = true
  Locomotive::Public::ContentEntriesController.any_instance.stubs(:protect_against_forgery?).returns(true)
end

Given /^I disable the CSRF protection for public submission requests$/ do
  Locomotive.config.csrf_protection = false
  # pending # express the regexp above with the code you wish you had
end

Then /^it returns a (\d+) error page$/ do |code|
  puts page.status_code
  page.status_code.should == code.to_i
end
