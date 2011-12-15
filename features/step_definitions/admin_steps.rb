### Authentication

Given /^I am not authenticated$/ do
  visit('/admin/sign_out')
end

Given /^I am an authenticated "([^"]*)"$/ do |role|
  @member = Site.first.memberships.where(:role => role.downcase).first || FactoryGirl.create(role.downcase.to_sym, :site => Site.first)

  step %{I go to login}
  step %{I fill in "Email" with "#{@member.account.email}"}
  step %{I fill in "Password" with "easyone"}
  step %{I press "Log in"}
end

Given /^I am an authenticated user$/ do
  step %{I am an authenticated "admin"}
end

Then /^I should see the access denied message$/ do
  step %{I should see "You are not authorized to access this page"}
end

Then /^I am redirected to "([^\"]*)"$/ do |url|
  assert [301, 302].include?(@integration_session.status), "Expected status to be 301 or 302, got #{@integration_session.status}"
  location = @integration_session.headers["Location"]
  assert_equal url, location
  visit location
end

### Cross-domain authentication

When /^I forget to press the button on the cross-domain notice page$/ do
  @admin.updated_at = 2.minutes.ago
  Mongoid::Persistence::Update.new(@admin).send(:update)
end

### Common

Then /^I debug$/ do
  debugger
  0
end
