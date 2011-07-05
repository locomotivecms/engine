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

Given /^I have a designer and an author$/ do
  Factory(:designer, :site => Site.first)
  Factory(:author, :site => Site.first)
end

Then /^I should be a administrator of the "([^"]*)" site$/ do |name|
  site = Site.where(:name => name).first
  m = site.memberships.detect { |m| m.account_id == @admin._id && m.admin? }
  m.should_not be_nil
end
