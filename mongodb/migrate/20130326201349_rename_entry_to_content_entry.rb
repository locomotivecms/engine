class RenameEntryToContentEntry < MongoidMigration::Migration

  def self.up
    regexp      = /(^|Locomotive::)(Content)*Entry([0-9a-fA-F]{24})$/
    replacement = "\\1ContentEntry\\3"

    # content entries
    self.update_content_entries(regexp, replacement)

    # content types
    self.update_content_types(regexp, replacement)

    # templatized pages
    self.update_templatized_pages(regexp, replacement)
  end

  def self.down
    regexp      = /(^|Locomotive::)(Content)+Entry([0-9a-fA-F]{24})$/
    replacement = "\\1Entry\\3"

    # content entries
    self.update_content_entries(regexp, replacement)

    # content types
    self.update_content_types(regexp, replacement)

    # templatized pages
    self.update_templatized_pages(regexp, replacement)
  end

  private

  def self.update_content_entries(regexp, replacement)
    self.fetch_rows(Locomotive::ContentEntry) do |collection, attributes|
      recipe      = attributes['custom_fields_recipe']
      type        = attributes['_type']
      new_recipe  = replace_value_by(recipe, regexp, replacement)
      selector    = { '_id' => attributes['_id'] }
      operations  = { '$set' => {
        '_type' => replace_value_by(type, regexp, replacement),
        'custom_fields_recipe' => new_recipe
      } }
      collection.find(selector).update(operations)
    end
    puts "content entries UPDATED"
  end

  def self.update_content_types(regexp, replacement)
    self.fetch_rows(Locomotive::ContentType) do |collection, attributes|
      updates       = {}
      attributes['entries_custom_fields'].each_with_index do |custom_field, index|
        new_custom_field = replace_value_by(custom_field, regexp, replacement)
        updates["entries_custom_fields.#{index}"] = new_custom_field
      end

      selector    = { '_id' => attributes['_id'] }
      operations  = { '$set' => updates }
      collection.find(selector).update(operations)
    end
    puts "content types UPDATED"
  end

  def self.update_templatized_pages(regexp, replacement)
    self.fetch_rows(Locomotive::Page) do |collection, attributes|
      if klass_name = attributes['target_klass_name']
        new_klass_name  = replace_value_by(klass_name, regexp, replacement)
        selector        = { '_id' => attributes['_id'] }
        operations      = { '$set' => { 'target_klass_name' => new_klass_name } }
        collection.find(selector).update(operations)
      end
    end
    puts "templatized pages UPDATED"
  end

  def self.fetch_rows(klass, &block)
    per_page    = 100
    collection  = klass.collection
    count       = collection.find.count
    num_pages   = (count.to_f / per_page).floor

    # paginate the whole collection to avoid mongodb cursor error
    (0..num_pages).each do |page|
      offset = per_page * page.to_i
      collection.find.skip(offset).limit(per_page).sort(_id: 1).each do |attributes|
        block.call(collection, attributes)
      end
    end
  end

  def self.replace_value_by(object, regexp, replacement)
    return object.gsub(regexp, replacement) if object.is_a?(String)

    list = nil
    list = object if object.is_a?(Array)
    list = object.values if object.is_a?(Hash)

    list.each do |value|
      case value
      when String then value.gsub!(regexp, replacement)
      when Array, Hash then self.replace_value_by(value, regexp, replacement)
      end
    end

    object
  end

end
