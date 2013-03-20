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

Then(/^I should see "(.*?)" in the html code$/) do |content|
  page.body.include?(content).should be_true
end

Then(/^I should not see "(.*?)" in the html code$/) do |content|
  page.body.include?(content).should be_false
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

Then /^the response status should be (\d+)$/ do |status|
  page.status_code.should == status.to_i
end

Then /^it returns a (\d+) error page$/ do |code|
  page.status_code.should == code.to_i
end

Then /^I should see the following xml output:$/ do |xml_output|
  xml_output.gsub!(':now', Date.today.to_s)
  response = Hash.from_xml(page.source)
  expected = Hash.from_xml(xml_output)
  expected.diff(response).should == {}
end

def wait_for_ajax(&block)
  start_time = Time.now
  while Time.now < start_time + Capybara.default_wait_time
    begin
      block.call
      break
    rescue RSpec::Expectations::ExpectationNotMetError => e
      raise e
    rescue
      # Try again
    end
  end
end

Then /^after the AJAX finishes, (.*)$/ do |*args|
  step_str = args[0]
  step_arg = args[1]
  wait_for_ajax do
    step(step_str, step_arg)
  end
end
