# Creates a Locomotive::Site record
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
  FactoryGirl.create(:designer, :site => Locomotive::Site.first)
  FactoryGirl.create(:author, :site => Locomotive::Site.first)
end

Given /^the site "(.*?)" has locales "(.*?)"$/ do |name, locales|
  site = Locomotive::Site.where(:name => name).first
  site.locales = locales.split(',').map(&:strip)
  site.save
end

Then /^I should be a administrator of the "([^"]*)" site$/ do |name|
  site = Locomotive::Site.where(:name => name).first
  m = site.memberships.detect { |m| m.account_id == @admin._id && m.admin? }
  m.should_not be_nil
end

# sets the robot_txt for a site

Given /^a robot_txt set to "([^"]*)"$/ do |value|
  @site.update_attributes(:robots_txt => value)
end

Then /^I should be able to add a domain to my site$/ do
  visit edit_current_site_path

  fill_in 'domain', :with => 'monkeys.com'
  click_link '+ add'
  click_button 'Save'

  page.should have_content 'My site was successfully updated'
  @site.reload.domains.should include 'monkeys.com'
end

Then /^I should be able to remove a domain from my site$/ do
  @site.domains = [ 'monkeys.com' ]
  @site.save!

  visit edit_current_site_path

  click_link 'x'
  click_button 'Save'

  page.should have_content 'My site was successfully updated'
  @site.reload.domains_without_subdomain.should be_blank
end

Then /^I should be able to remove a membership from my site$/ do
  @new_account = FactoryGirl.create(:author, :site => @site)
  @site.save!

  visit edit_current_site_path

  click_link 'x'
  click_button 'Save'

  page.should have_content 'My site was successfully updated'
  @site.reload.memberships.collect(&:account).should_not include(@new_account)
end
