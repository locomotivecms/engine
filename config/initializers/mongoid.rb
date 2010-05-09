File.open(File.join(Rails.root, 'config/database.yml'), 'r') do |f|
  @settings = YAML.load(f)[Rails.env]
end

Mongoid.configure do |config|
  name = @settings["database"]
  host = @settings["host"]
  config.master = Mongo::Connection.new.db(name)
  # config.slaves = [
  #   Mongo::Connection.new(host, @settings["slave_one"]["port"], :slave_ok => true).db(name),
  #   Mongo::Connection.new(host, @settings["slave_two"]["port"], :slave_ok => true).db(name)
  # ]
end

## various patches


module Mongoid #:nodoc:
  
  # Enabling scope in validates_uniqueness_of validation
  module Validations #:nodoc:
    class UniquenessValidator < ActiveModel::EachValidator
      def validate_each(document, attribute, value, scope = nil)
        criteria = { attribute => value, :_id.ne => document._id }        
        criteria[scope] = document.send(scope) if scope        
        return if document.class.where(criteria).empty?
        document.errors.add(attribute, :taken, :default => options[:message], :value => value)
      end
    end
  end
  
  # FIX BUG #71 http://github.com/durran/mongoid/commit/47a97094b32448aa09965c854a24c78803c7f42e
  module Associations
    module InstanceMethods      
      def update_embedded(name)
        association = send(name)
        association.to_a.each { |doc| doc.save if doc.changed? || doc.new_record? } unless association.blank?
      end      
    end
  end
end