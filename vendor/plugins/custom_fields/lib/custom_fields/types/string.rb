module CustomFields
  module Types
    module String
        
      extend ActiveSupport::Concern
      
      included do
        register_type :string
      end
          
    end
  end
end