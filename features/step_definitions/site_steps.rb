# Creates a Locomotive::Site record
#
# examples:
# - I have the site: "some site" set up
# - I have the site: "some site" set up with name: "Something", domain: "test2"
#
Given /^I have the site: "([^"]*)" set up(?: with #{capture_fields})?$/ do |site_factory, fields|
  Thread.current[:site] = nil
  attributes = parse_fields(fields)
  id    = attributes.delete('id')
  @site = FactoryGirl.build(site_factory, attributes)
  @site.id = id if id
  @site.save & @site.reload
  @site.should_not be_nil

  @admin = @site.memberships.first.account
  @admin.should_not be_nil
  # same api key for all the tests
  @admin.api_key = 'd49cd50f6f0d2b163f48fc73cb249f0244c37074'
  @admin.save
end

Given /^I have a site set up$/ do
  step %{I have the site: "test site" set up}
end

Given /^I have a designer and an author$/ do
  site = Locomotive::Site.first
  FactoryGirl.create(:designer, site: site)
  FactoryGirl.create(:author, site: site)
end

Given /^the site "(.*?)" has locales "(.*?)"$/ do |name, locales|
  site = Locomotive::Site.where(name: name).first
  site.update_attribute :locales, locales.split(',').map(&:strip)

  # very important to set the locale fallbacks
  site.locales.each do |locale|
    ::Mongoid::Fields::I18n.fallbacks_for(locale, site.locale_fallbacks(locale))
  end
end

Given /^multi_sites is disabled$/ do
  Locomotive.config.multi_sites = false
  Locomotive.after_configure
end

Then /^I should be a administrator of the "([^"]*)" site$/ do |name|
  site = Locomotive::Site.where(name: name).first
  m = site.memberships.detect { |m| m.account_id == @admin._id && m.admin? }
  m.should_not be_nil
end

# sets the robot_txt for a site

Given /^a robot_txt set to "([^"]*)"$/ do |value|
  @site.update_attributes(robots_txt: value)
end

Then /^I should be able to add a domain to my site$/ do
  visit edit_current_site_path

  within('#site_domains_input') do
    fill_in 'domain', with: 'monkeys.com'
  end
  click_link '+ add'
  click_button 'Save'

  page.should have_content 'My site was successfully updated'
  @site.reload.domains.should include 'monkeys.com'
end

Then /^I should be able to remove a domain from my site$/ do
  @site.domains = [ 'monkeys.com' ]
  @site.save!

  visit edit_current_site_path

  click_link 'Delete'
  click_button 'Save'

  page.should have_content 'My site was successfully updated'
  @site.reload.domains_without_subdomain.should be_blank
end

Then /^I should be able to remove a membership from my site$/ do
  @new_account = FactoryGirl.create(:author, site: @site)
  @site.save!

  visit edit_current_site_path

  click_link 'Delete'
  click_button 'Save'

  page.should have_content 'My site was successfully updated'
  @site.reload.memberships.collect(&:account).should_not include(@new_account)
end

Then /^I should be able to save the site with AJAX$/ do
  visit edit_current_site_path

  # Prevent the default behaviour so we're sure it's AJAX
  js = <<-EOF
    $('form').submit(function(event) {
      event.preventDefault();
    });
  EOF
  page.execute_script(js)

  click_button 'Save'
  page.should have_content 'My site was successfully updated'
end
