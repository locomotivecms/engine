module Locomotive    
  module Liquid    
    module Drops  
      class Content < Base
        
        def before_method(meth)
          return '' if @source.nil?
      
          if not @@forbidden_attributes.include?(meth.to_s)
            @source.send(meth)
          end
        end
        
      end  
    end
  end  
end