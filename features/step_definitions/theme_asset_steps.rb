### Theme assets

# helps create a theme asset
def create_plain_text_asset(name, type)
  asset = FactoryGirl.build(:theme_asset, {
    :site => @site,
    :plain_text_name => name,
    :plain_text => 'Lorem ipsum',
    :plain_text_type => type,
    :performing_plain_text => true
  })
  # asset.should be_valid
  asset.save!

end

# creates various theme assets

Given /^a javascript asset named "([^"]*)"$/ do |name|
  @asset = create_plain_text_asset(name, 'javascript')
end

Given /^a stylesheet asset named "([^"]*)"$/ do |name|
  @asset = create_plain_text_asset(name, 'stylesheet')
end

Given /^I have an image theme asset named "([^"]*)"$/ do |name|
  @asset = FactoryGirl.create(:theme_asset, :site => @site, :source => File.open(Rails.root.join('spec', 'fixtures', 'assets', '5k.png')))
  @asset.source_filename = name
  @asset.save!
end


# other stuff

Then /^I should see "([^"]*)" as theme asset code$/ do |code|
  find(:css, "#theme_asset_plain_text").text.should == code
end

Then /^I should see a delete image button$/ do
  page.has_css?("ul.theme-assets li .more a.remove").should be_true
end

Then /^I should not see a delete image button$/ do
  page.has_css?("ul.theme-assets li .more a.remove").should be_false
end
