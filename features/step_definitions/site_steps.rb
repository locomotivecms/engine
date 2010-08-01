# Creates a Site record
#
# examples:
# - I have the site: "some site" set up
# - I have the site: "some site" set up with name: "Something", domain: "test2"
#
Given /^I have the site: "([^"]*)" set up(?: with #{capture_fields})?$/ do |site_factory, fields|
  @site = Factory(site_factory, parse_fields(fields))
  @site.should_not be_nil

  @admin = @site.memberships.first.account
  @admin.should_not be_nil
end

