### Authentication

Given /^I am not authenticated$/ do
  visit('/admin/sign_out')
end

Given /^I am an authenticated user$/ do
  Given %{I go to login}
  And %{I fill in "Email" with "admin@locomotiveapp.org"}
  And %{I fill in "Password" with "easyone"}
  And %{I press "Log in"}
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

