class NumberOfEntries < MongoidMigration::Migration
  def self.up
    collection = Locomotive::ContentType.collection

    Locomotive::ContentType.all.each do |type|
      selector    = { '_id' => type._id }
      operations  = { '$set' => { 'number_of_entries' => type.entries.count } }
      collection.find(selector).update(operations)
    end
  end

  def self.down

  end
end