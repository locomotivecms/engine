# Creates a Site record
#
# examples:
# - I have the site: "some site" set up
# - I have the site: "some site" set up with name: "Something", domain: "test2"
#
Given /^I have the site: "([^"]*)" set up(?: with #{capture_fields})?$/ do |site_factory, fields|
  Thread.current[:site] = nil
  @site = FactoryGirl.create(site_factory, parse_fields(fields))
  @site.should_not be_nil

  @admin = @site.memberships.first.account
  @admin.should_not be_nil
end

Given /^I have a site set up$/ do
  step %{I have the site: "test site" set up}
end

Given /^I have a designer and an author$/ do
  FactoryGirl.create(:designer, :site => Site.first)
  FactoryGirl.create(:author, :site => Site.first)
end

Then /^I should be a administrator of the "([^"]*)" site$/ do |name|
  site = Site.where(:name => name).first
  m = site.memberships.detect { |m| m.account_id == @admin._id && m.admin? }
  m.should_not be_nil
end

# sets the robot_txt for a site

Given /^a robot_txt set to "([^"]*)"$/ do |value|
  @site.update_attributes(:robots_txt => value)
end
