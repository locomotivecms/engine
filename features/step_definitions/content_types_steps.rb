def build_content_type(name)
  site = Locomotive::Site.first
  FactoryGirl.build(:content_type, :site => site, :name => name, :order_by => '_position')
end

def set_custom_fields_from_table(content_type, fields)
  fields.hashes.each do |field|
    # found a belongs_to association
    if field['type'] == 'belongs_to'
      target_name   = field.delete('target')
      target_model  = @site.content_types.where(:name => target_name).first

      field['class_name'] = target_model.klass_with_custom_fields(:entries).to_s
    end

    content_type.entries_custom_fields.build field
  end
end

Given %r{^I have a custom model named "([^"]*)" with id "([^"]*)" and$} do |name, id, fields|
  content_type = build_content_type(name)
  content_type.id = BSON::ObjectId(id)
  set_custom_fields_from_table(content_type, fields)
  content_type.valid?
  content_type.save.should be_true
end

Given %r{^I have a custom model named "([^"]*)" with$} do |name, fields|
  content_type = build_content_type(name)
  set_custom_fields_from_table(content_type, fields)
  content_type.valid?
  content_type.save.should be_true
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

Given %r{^I (enable|disable) the public submission of the "([^"]*)" model$} do |action, name|
  enabled = action == 'enable'
  content_type = Locomotive::ContentType.where(:name => name).first
  content_type.public_submission_enabled  = enabled
  content_type.public_submission_accounts = enabled ? [Locomotive::Account.first._id] : []
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
