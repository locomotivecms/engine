module Models  
  module Extensions    
    module Page      
      module Templatized  

        extend ActiveSupport::Concern

        included do
                              
          belongs_to_related :content_type
          
          field :templatized, :type => Boolean, :default => false
          
          field :content_type_visible_column
          
          before_validation :set_slug_if_templatized
        end
        
        module InstanceMethods
          
          def set_slug_if_templatized
            self.slug = 'content_type_template' if self.templatized?
          end
                  
        end
        
      end
    end
  end
end
      
      