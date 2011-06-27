Given /^I have a custom project model/ do
  site = Site.first
  @content_type = Factory.build(:content_type, :site => site, :name => 'Projects')
  @content_type.content_custom_fields.build :label => 'Name', :kind => 'string'
  @content_type.content_custom_fields.build :label => 'Description', :kind => 'text'
  @content_type.save.should be_true
end