Given %r{^I have a custom model named "([^"]*)" with$} do |name, fields|
  site = Locomotive::Site.first
  content_type = FactoryGirl.build(:content_type, :site => site, :name => name)
  fields.hashes.each do |field|
    if (target_name = field.delete('target')).present?
      target_content_type = site.content_types.where(:name => target_name).first
      field['target'] = target_content_type.content_klass.to_s
    end

    content_type.entries_custom_fields.build field
  end
  content_type.valid?
  content_type.save.should be_true
end

Given /^I set up a reverse has_many relationship between "([^"]*)" and "([^"]*)"$/ do |name_1, name_2|
  site = Locomotive::Site.first

  content_type_1 = site.content_types.where(:name => name_1).first
  content_type_2 = site.content_types.where(:name => name_2).first

  content_type_1.entries_custom_fields.build({
    :label          => name_2,
    :type           => 'has_many',
    :target         => content_type_2.content_klass.to_s,
    :reverse_lookup => content_type_2.content_klass.custom_field_alias_to_name(name_1.downcase.singularize)
  })

  content_type_1.save.should be_true
end

Given %r{^I have "([^"]*)" as "([^"]*)" values of the "([^"]*)" model$} do |values, field, name|
  content_type = Locomotive::ContentType.where(:name => name).first
  field = content_type.entries_custom_fields.detect { |f| f.label == field }
  field.should_not be_nil

  if field.type == 'select'
    values.split(',').collect(&:strip).each do |name|
      field.select_options.build :name => name
    end
    content_type.save.should be_true
  else
    raise "#{field.type} field is not supported"
  end
end

Given %r{^I have entries for "([^"]*)" with$} do |name, entries|
  content_type = Locomotive::ContentType.where(:name => name).first
  entries.hashes.each do |entry|
    content_type.entries.create(entry)
  end
  content_type.save.should be_true
end

When %r{^I change the presentation of the "([^"]*)" model by grouping items by "([^"]*)"$} do |name, field|
  content_type = Locomotive::ContentType.where(:name => name).first
  field = content_type.entries_custom_fields.detect { |f| f.label == field }
  content_type.group_by_field_id = field._id
  content_type.save.should be_true
end

Then %r{^I should not see (\d+) times the "([^"]*)" field$} do |n, field|
  page.all(:css, "#content_#{field.underscore.downcase}_input").size.should_not == n.to_i
end

Then %r{^I should see once the "([^"]*)" field$} do |field|
  page.should have_css("#content_#{field.underscore.downcase}_input", :count => 1)
end
