Given %r{^I have a custom model named "([^"]*)" with$} do |name, fields|
  site = Site.first
  content_type = Factory.build(:content_type, :site => site, :name => name)
  fields.hashes.each do |field|
    f = content_type.content_custom_fields.build field
  end
  content_type.valid?
  content_type.save.should be_true
end

Given %r{^I have "([^"]*)" as "([^"]*)" values of the "([^"]*)" model$} do |values, field, name|
  content_type = ContentType.where(:name => name).first
  field = content_type.content_custom_fields.detect { |f| f.label == field }
  field.should_not be_nil

  if field.category?
    values.split(',').collect(&:strip).each do |name|
      field.category_items.build :name => name
    end
    content_type.save.should be_true
  else
    raise "#{field.kind} field is not supported"
  end
end

Given %r{^I have entries for "([^"]*)" with$} do |name, entries|
  content_type = ContentType.where(:name => name).first
  entries.hashes.each do |entry|
    content_type.contents.create(entry)
  end
  content_type.save.should be_true
end

When %r{^I change the presentation of the "([^"]*)" model by grouping items by "([^"]*)"$} do |name, field|
  content_type = ContentType.where(:name => name).first
  field = content_type.content_custom_fields.detect { |f| f.label == field }
  content_type.group_by_field_name = field._name
  content_type.save.should be_true
end