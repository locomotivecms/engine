When(/^the locale of the current ruby thread changes to "(.*?)"$/) do |locale|
  ::I18n.locale = ::Mongoid::Fields::I18n.locale = 'fr'
end

When /^I follow image link "([^"]*)"$/ do |img_alt|
  find(:xpath, "//img[@alt = '#{img_alt}']/parent::a").click()
end

When /^I click on the "([^"]*)" folder$/ do |name|
  find('fieldset.foldable legend span', text: name).click
end

Then /^I should get a download with the filename "([^\"]*)"$/ do |filename|
  page.response_headers['Content-Disposition'].should include("filename=#{filename}")
end

When /^I wait until "([^"]*)" is visible$/ do |selector|
  page.has_css?("#{selector}", visible: true)
end

When /^I wait until ([^"]*) is visible$/ do |locator|
  page.has_css?(selector_for(locator), visible: true)
end

When /^I sync my form with my backbone model because of Firefox$/ do
  page.execute_script("$(':input').trigger('change')")
end

When /^I fill in "(.*?)" with the tags "(.*?)"$/ do |field, tags|
  input = field_labeled(field)
  tags.split(',').each do |tag|
    _tag = tag.strip
    page.execute_script("$('input[name=\"#{input[:name]}\"]').tagit('createTag', '#{_tag}')")
  end
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

When(/^I switch the locale to "(.*?)"$/) do |locale|
  click_on 'content-locale-picker-link'
  within '#content-locale-picker' do
    find("[data-locale='#{locale}']").click
  end
end

Then(/^I should see a "(.*?)" link to "(.*?)"$/) do |text, path|
  page.should have_link(text, href: path)
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
  xml_output.gsub!(':now', Time.now.utc.to_date.to_s)
  response = Hash.from_xml(page.source)
  expected = Hash.from_xml(xml_output)
  expected.diff(response).should == {}
end

When /^I take a screenshot$/ do
  page.save_screenshot('/Users/didier/Desktop/cucumber.png', full: true)
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

When(/^I wait (\d+)ms$/) do |delay|
  sleep(delay.to_i / 1000.0)
end
