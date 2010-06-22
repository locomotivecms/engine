module CustomFields
  module Types
    module Text
        
      extend ActiveSupport::Concern
      
      included do
        field :text_formatting, :default => 'html'
        
        register_type :text
      end
    
    end
  end
end