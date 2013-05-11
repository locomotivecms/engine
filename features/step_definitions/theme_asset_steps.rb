### Theme assets

# helps create a theme asset
def new_plain_text_asset(name, type)
  FactoryGirl.build(:theme_asset, {
    :site                   => @site,
    :plain_text_name        => name,
    :plain_text             => 'Lorem ipsum',
    :plain_text_type        => type,
    :performing_plain_text  => true
  })
end

def create_plain_text_asset(name, type)
  asset = new_plain_text_asset(name, type)
  asset.save!
end

# creates various theme assets

Given /^a javascript asset named "([^"]*)"$/ do |name|
  @asset = create_plain_text_asset(name, 'javascript')
end

Given /^a javascript asset named "([^"]*)" with id "([^"]*)"$/ do |name, id|
  @asset = new_plain_text_asset(name, 'javascript')
  @asset.id = Moped::BSON::ObjectId(id)
  @asset.save!
end

Given /^a stylesheet asset named "([^"]*)"$/ do |name|
  @asset = create_plain_text_asset(name, 'stylesheet')
end

Given /^a stylesheet asset named "([^"]*)" with id "([^"]*)"$/ do |name, id|
  @asset = new_plain_text_asset(name, 'stylesheet')
  @asset.id = Moped::BSON::ObjectId(id)
  @asset.save!
end

Given /^I have an image theme asset named "([^"]*)"$/ do |name|
  @asset = FactoryGirl.create(:theme_asset, :site => @site, :source => File.open(Rails.root.join('..', 'fixtures', 'assets', '5k.png')))
  @asset.source_filename = name
  @asset.save!
end

# other stuff

# change the template
When /^I change the theme asset code to "([^"]*)"$/ do |plain_text|
  page.evaluate_script "window.application_view.view.editor.setValue('#{plain_text}')"
end

Then /^I should see "([^"]*)" as the theme asset code$/ do |code|
  find(:css, "#theme_asset_plain_text").value.should == code
end

Then /^I should see a delete link$/ do
  page.has_css?(".box ul li .more a.remove").should be_true
end

Then /^I should not see a delete link$/ do
  page.has_css?(".box ul li .more a.remove").should be_false
end
