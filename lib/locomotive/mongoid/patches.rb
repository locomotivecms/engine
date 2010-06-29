require 'mongoid'

## various patches
module Mongoid #:nodoc:
  
  # Enabling scope in validates_uniqueness_of validation
  module Validations #:nodoc:
    class UniquenessValidator < ActiveModel::EachValidator
      def validate_each(document, attribute, value)
        conditions = { attribute => value, :_id.ne => document._id }
        
        if options.has_key?(:scope) && !options[:scope].nil?
          [*options[:scope]].each do |scoped_attr|
            conditions[scoped_attr] = document.attributes[scoped_attr]
          end
        end
      
        return if document.class.where(conditions).empty?
      
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
    
    class EmbedsMany < Proxy
      
      def nested_build(attributes, options = {})
        deleted_indexes = []
        attributes.each do |index, attrs|
          if document = detect { |document| document._index == index.to_i }
            if options && options[:allow_destroy] && attrs['_destroy']
              deleted_indexes << document._index
              @target.delete(document)
              document.destroy
            else
              document.write_attributes(attrs)
              document._index = index.to_i - deleted_indexes.collect { |i| i < index.to_i }.size
            end
          else
            build(attrs)
          end
        end
      end
      
    end
  end
  
  # FIX BUG about accepts_nested_attributes_for  
  module Document
    module InstanceMethods
      def remove(child)
        name = child.association_name
        @attributes.remove(name, child.raw_attributes)
      end
    end
  end
  
  
end