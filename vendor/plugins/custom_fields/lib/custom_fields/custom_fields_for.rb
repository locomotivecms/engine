module CustomFields
  
  module CustomFieldsFor
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # Enhance an embedded collection by providing methods to manage custom fields
    #
    # class Person
    #   embeds_many :addresses
    #   custom_fields_for :addresses
    # end
    #
    # class Address
    #    embedded_in :person, :inverse_of => :addresses
    #    field :street, String
    # end
    #
    # person.address_fields.build :label => 'Floor', :kind => 'String'
    #
    # person.addresses.build :street => 'Laflin Street', :floor => '42'
    #
    module ClassMethods
      
      def custom_fields_for(collection_name)
        puts "settings custom fields for #{collection_name}"
        
        singular_name = collection_name.to_s.singularize
        
        class_eval <<-EOV
          field :#{singular_name}_custom_fields_counter, :type => Integer, :default => 0
          
          embeds_many :#{singular_name}_custom_fields, :class_name => "::CustomFields::CustomField"
          
          accepts_nested_attributes_for :#{singular_name}_custom_fields, :allow_destroy => true
        EOV
      end
      
    end
    
  end
  
end