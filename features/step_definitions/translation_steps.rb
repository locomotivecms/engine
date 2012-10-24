Given /^a translation with key "(.*?)" and id "(.*?)" with values:$/ do |key, id, table|
  translation = @site.translations.build
  translation.id = BSON::ObjectId(id)
  translation.key = key
  translation.values = table.raw.inject({}) { |memo,values| memo.merge(values.first => values.last) }
  translation.save!
end