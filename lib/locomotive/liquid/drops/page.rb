module Locomotive  
  module Liquid    
    module Drops    
      class Page < Base
        
        liquid_attributes << :title << :slug
        
        def children
          @children ||= liquify(*@source.children)
        end
        
        def fullpath
          @fullpath ||= @source.fullpath
        end
        
      end
    end
  end
end