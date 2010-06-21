module Locomotive  
  module Liquid    
    module Drops    
      class Page < Base
        
        liquid_attributes << :title << :fullpath
        
        def children
          @children ||= liquify(*@source.children)
        end
        
      end
    end
  end
end