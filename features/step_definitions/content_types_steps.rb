Given %r{^I have a custom model named "([^"]*)" with$} do |name, fields|
  site = Site.first
  content_type = Factory.build(:content_type, :site => site, :name => name)
  fields.hashes.each do |field|
    if (target_name = field.delete('target')).present?
      target_content_type = site.content_types.where(:name => target_name).first
      field['target'] = target_content_type.content_klass.to_s
    end

    content_type.content_custom_fields.build field
  end
  content_type.valid?
  content_type.save.should be_true
end

Given /^I set up a reverse has_many relationship between "([^"]*)" and "([^"]*)"$/ do |name_1, name_2|
  site = Site.first

  content_type_1 = site.content_types.where(:name => name_1).first
  content_type_2 = site.content_types.where(:name => name_2).first

  content_type_1.content_custom_fields.build({
    :label          => name_2,
    :kind           => 'has_many',
    :target         => content_type_2.content_klass.to_s,
    :reverse_lookup => content_type_2.content_klass.custom_field_alias_to_name(name_1.downcase.singularize)
  })

  content_type_1.save.should be_true
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

Then %r{^I should not see (\d+) times the "([^"]*)" field$} do |n, field|
  page.all(:css, "#content_#{field.underscore.downcase}_input").size.should_not == n.to_i
end

Then %r{^I should see once the "([^"]*)" field$} do |field|
  page.all(:css, "#content_#{field.underscore.downcase}_input").size.should == 1
end

