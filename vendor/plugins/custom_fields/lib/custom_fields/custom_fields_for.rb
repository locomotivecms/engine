module CustomFields
  
  module CustomFieldsFor
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # Enhance an embedded collection by providing methods to manage custom fields
    #
    # class Company
    #   embeds_many :employees
    #   custom_fields_for :employees
    # end
    #
    # class Employee
    #    embedded_in :company, :inverse_of => :employees
    #    field :name, String
    # end
    #
    # company.employee_custom_fields.build :label => 'His/her position', :_alias => 'position', :kind => 'String'
    #
    # company.employees.build :name => 'Michael Scott', :position => 'Regional manager'
    #
    module ClassMethods
      
      def custom_fields_for(collection_name)
        singular_name = collection_name.to_s.singularize
        
        class_eval <<-EOV
          field :#{singular_name}_custom_fields_counter, :type => Integer, :default => 0
          
          embeds_many :#{singular_name}_custom_fields, :class_name => "::CustomFields::Field"
          
          validates_associated :#{singular_name}_custom_fields
          
          accepts_nested_attributes_for :#{singular_name}_custom_fields, :allow_destroy => true
          
          def ordered_#{singular_name}_custom_fields
            self.#{singular_name}_custom_fields.sort { |a, b| (a.position || 0) <=> (b.position || 0) }
          end
          
        EOV
      end
      
    end
    
  end
  
end