Given /^I have a custom project model/ do
  site = Site.first
  @content_type = Factory.build(:content_type, :site => site, :name => 'Projects')
  @content_type.content_custom_fields.build :label => 'Name', :kind => 'string', :required => true
  @content_type.content_custom_fields.build :label => 'Description', :kind => 'text'
  @content_type.save.should be_true
end

Given /^I have a project entry with "(.*)" as name and "(.*)" as description/ do |name, description|
  @content = @content_type.contents.build :name => name, :description => description
  @content.save.should be_true
end