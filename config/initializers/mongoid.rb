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
      
        # Rails.logger.debug "conditions = #{conditions.inspect} / #{options[:scope].inspect}"
        
        return if document.class.where(conditions).empty?
      
        # if document.new_record? || key_changed?(document)
          document.errors.add(attribute, :taken, :default => options[:message], :value => value)
        # end
      end

      # protected
      # def key_changed?(document)
      #   (document.primary_key || {}).each do |key|
      #     return true if document.send("#{key}_changed?")
      #   end; false
      # end
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