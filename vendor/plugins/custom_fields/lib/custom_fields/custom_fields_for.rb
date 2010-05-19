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
        
        class_eval <<-EOV
          
        
        EOV
      end
      
    end
    
  end
  
end