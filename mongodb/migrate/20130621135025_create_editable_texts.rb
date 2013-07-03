class CreateEditableTexts < MongoidMigration::Migration
  def self.up
    self.pages.each do |page|
      attributes = {}

      page['editable_elements'].each_with_index do |element, index|
        next unless element['_type'] =~ /Text$/
        attributes.merge!(new_attributes_for(element['_type'], index))
      end

      self.update_page(page['_id'], attributes)
    end
  end

  def self.down

  end

  protected

  def self.new_attributes_for(type, index)
    {
      "editable_elements.#{index}._type"       => 'Locomotive::EditableText',
      "editable_elements.#{index}.format"      => type.ends_with?('LongText') ? 'html' : 'raw',
      "editable_elements.#{index}.rows"        => type.ends_with?('LongText') ? 15 : 2,
      "editable_elements.#{index}.line_break"  => type.ends_with?('LongText') ? true : false
    }
  end

  def self.pages
    Locomotive::Page.collection.find('editable_elements._type' => {
      '$in' => ['Locomotive::EditableShortText', 'Locomotive::EditableLongText']
    })
  end

  def self.update_page(id, attributes)
    selector      = { '_id' => id }
    modifications = { '$set' => attributes }
    Locomotive::Page.collection.find(selector).update(modifications)
  end

end